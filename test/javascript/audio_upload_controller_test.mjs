import { test, beforeEach } from "node:test"
import assert from "node:assert/strict"
import { readFile } from "node:fs/promises"

const source = await readFile(new URL("../../app/javascript/controllers/audio_upload_controller.js", import.meta.url), "utf8")
const { default: Upload } = await import(`data:text/javascript;base64,${Buffer.from(source.replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")).toString("base64")}`)

let controller, metadataAudio, saveButton
beforeEach(() => {
  saveButton = { disabled: false }
  globalThis.document = { querySelectorAll: () => [saveButton] }
  globalThis.URL = { createObjectURL: () => "blob:sample", revokeObjectURL() {} }
  globalThis.Audio = class {
    constructor() { metadataAudio = this }
    removeAttribute() {}
    load() {}
  }
  controller = new Upload()
  controller.element = { id: "audio-sample-form", setAttribute() {} }
  controller.fileTarget = { files: [], value: "" }
  controller.durationTarget = { value: "" }
  controller.feedbackTarget = { hidden: true }
  controller.progressTarget = { hidden: false, value: 0 }
  controller.statusTarget = { textContent: "" }
  controller.errorTarget = { hidden: true, textContent: "", focus() { this.focused = true } }
  controller.connect()
})

test("reads duration from a valid MP3 before allowing save", () => {
  controller.fileTarget.files = [{ name: "birds.mp3", type: "audio/mpeg", size: 1024 }]
  controller.selected()
  assert.equal(saveButton.disabled, true)

  metadataAudio.duration = 61.2345
  metadataAudio.onloadedmetadata()
  assert.equal(controller.durationTarget.value, "61.234")
  assert.equal(saveButton.disabled, false)

  let prevented = false
  controller.validate({ preventDefault() { prevented = true } })
  assert.equal(prevented, false)
})

for (const [file, message] of [
  [{ name: "birds.wav", type: "audio/wav", size: 1024 }, /MP3/],
  [{ name: "birds.mp3", type: "audio/mpeg", size: 20 * 1024 * 1024 + 1 }, /20 MiB/]
]) {
  test(`rejects ${file.name} when it violates upload constraints`, () => {
    controller.fileTarget.files = [file]
    controller.selected()
    assert.match(controller.errorTarget.textContent, message)
    assert.equal(controller.errorTarget.hidden, false)
    assert.equal(controller.fileTarget.value, "")
  })
}

test("reports direct upload progress and errors", () => {
  controller.uploadStarted()
  controller.uploadProgress({ detail: { progress: 42.4 } })
  assert.equal(controller.progressTarget.value, 42)
  assert.equal(controller.statusTarget.textContent, "Uploading… 42%")

  let prevented = false
  controller.uploadFailed({ detail: { error: "Network unavailable" }, preventDefault() { prevented = true } })
  assert.equal(prevented, true)
  assert.equal(saveButton.disabled, false)
  assert.equal(controller.errorTarget.textContent, "Network unavailable")
})

test("an invalid replacement restores the existing attachment duration", () => {
  controller.durationTarget.value = "45.500"
  controller.connect()
  controller.fileTarget.files = [{ name: "birds.wav", type: "audio/wav", size: 1024 }]

  controller.selected()

  assert.equal(controller.durationTarget.value, "45.500")
  assert.equal(controller.ready, true)
})
