import { test, beforeEach } from "node:test"
import assert from "node:assert/strict"
import { readFile } from "node:fs/promises"

// Load the controller without the browser's import map; Stimulus supplies its targets.
const source = await readFile(new URL("../../app/javascript/controllers/game_upload_controller.js", import.meta.url), "utf8")
const { default: Upload } = await import(`data:text/javascript;base64,${Buffer.from(source.replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')).toString("base64")}`)
let controller, requests, button, destination
beforeEach(() => {
  requests = []
  destination = null
  globalThis.XMLHttpRequest = class {
    constructor() { this.upload = {}; this.headers = {}; requests.push(this) }
    open(method, url) { this.method = method; this.url = url }
    setRequestHeader(name, value) { this.headers[name] = value }
    send(data) { this.data = data }
    abort() { this.aborted = true; this.onabort?.() }
  }
  globalThis.FormData = class { constructor(form) { this.form = form } }
  globalThis.document = { querySelector: () => ({ content: "csrf-token" }) }
  globalThis.window = { location: { href: "https://example.com/games/new", assign: (url) => { destination = url } } }
  button = { type: "submit", disabled: false }
  controller = new Upload()
  controller.element = { method: "post", action: "/games", elements: [button], setAttribute() {} }
  for (const name of ["feedback", "progress", "status", "error"]) {
    controller[`${name}Target`] = { hidden: true, textContent: "", focus() { this.focused = true }, removeAttribute(name) { delete this[name] } }
  }
})
const submit = () => controller.submit({ preventDefault() {} })
const respond = (status, body, url = "https://example.com/games") => {
  Object.assign(requests[0], { status, responseText: body, responseURL: url })
  requests[0].onload()
}

test("sends multipart form and CSRF token once, with progress and saving feedback", () => {
  submit()
  submit()
  assert.equal(requests.length, 1)
  assert.equal(button.disabled, true)
  assert.equal(requests[0].data.form, controller.element)
  assert.deepEqual(requests[0].headers, { Accept: "application/json", "X-CSRF-Token": "csrf-token" })
  requests[0].upload.onprogress({ lengthComputable: true, loaded: 50, total: 100 })
  assert.equal(controller.progressTarget.value, 50)
  assert.equal(controller.statusTarget.textContent, "Uploading… 50%")
  requests[0].upload.onload()
  assert.match(controller.statusTarget.textContent, /Saving game/)
  respond(200, '{"location":"/games/42"}')
  assert.equal(destination, "/games/42")
})

test("unknown upload length uses an indeterminate progress bar", () => {
  submit()
  requests[0].upload.onprogress({ lengthComputable: false })
  assert.equal(controller.progressTarget.value, undefined)
})

for (const [status, body, url, expected] of [
  [413, "<html>Too large</html>", undefined, /upload limit/],
  [422, '{"errors":["Title cannot be blank","URL slug is taken"]}', undefined, /Title cannot be blank URL slug is taken/],
  [422, "Invalid token", undefined, /session could not be verified/],
  [401, "", undefined, /session has expired/],
  [200, "<html>Sign in</html>", "https://example.com/session/new", /session has expired/],
  [406, "", "https://example.com/session/new", /session has expired/],
  [502, "<html>Bad gateway</html>", undefined, /could not confirm/],
  [200, "not json", undefined, /could not confirm/]
]) {
  test(`handles ${status} ${body || url} without discarding the form`, () => {
    const form = controller.element
    submit()
    respond(status, body, url)
    assert.match(controller.errorTarget.textContent, expected)
    assert.equal(controller.errorTarget.hidden, false)
    assert.equal(controller.errorTarget.focused, true)
    assert.equal(controller.element, form)
    assert.equal(button.disabled, false)
    assert.equal(destination, null)
    submit()
    assert.equal(requests.length, 2)
    assert.equal(controller.errorTarget.hidden, true)
  })
}

for (const [event, expected] of [["onerror", /Connection lost/], ["ontimeout", /timed out/], ["onabort", /cancelled/]]) {
  test(`${event} restores Save and shows a message`, () => {
    submit()
    requests[0][event]()
    assert.match(controller.errorTarget.textContent, expected)
    assert.equal(button.disabled, false)
    assert.equal(controller.progressTarget.hidden, true)
  })
}

test("leaving the form aborts an active upload", () => {
  submit()
  controller.disconnect()
  assert.equal(requests[0].aborted, true)
  assert.equal(button.disabled, false)
  assert.equal(controller.request, null)
})
