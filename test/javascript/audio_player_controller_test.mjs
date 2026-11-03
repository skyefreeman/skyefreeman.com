import { test, beforeEach } from "node:test"
import assert from "node:assert/strict"
import { readFile } from "node:fs/promises"

const source = await readFile(new URL("../../app/javascript/controllers/audio_player_controller.js", import.meta.url), "utf8")
const { default: Player } = await import(`data:text/javascript;base64,${Buffer.from(source.replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")).toString("base64")}`)

let controller, audio, dispatched
beforeEach(() => {
  dispatched = null
  globalThis.CustomEvent = class { constructor(type, options) { this.type = type; this.detail = options.detail } }
  globalThis.window = { dispatchEvent: (event) => { dispatched = event } }
  audio = {
    paused: true,
    currentTime: 12,
    play() { this.paused = false; return Promise.resolve() },
    pause() { this.paused = true; this.pauseCalls = (this.pauseCalls || 0) + 1 }
  }
  controller = new Player()
  controller.element = { id: "first" }
  controller.hasAudioTarget = true
  controller.audioTarget = audio
  controller.buttonTarget = {
    attributes: {},
    dataset: { playLabel: "Play Morning birds", pauseLabel: "Pause Morning birds" },
    setAttribute(name, value) { this.attributes[name] = value }
  }
  controller.labelTarget = { textContent: "Play" }
  controller.errorTarget = { hidden: true, textContent: "" }
})

test("toggles playback and reflects the playing state", async () => {
  controller.toggle()
  assert.equal(audio.paused, false)
  controller.playing()
  assert.equal(controller.labelTarget.textContent, "Pause")
  assert.equal(controller.buttonTarget.attributes["aria-pressed"], "true")
  assert.equal(dispatched.type, "audio-player:started")

  controller.toggle()
  assert.equal(audio.paused, true)
})

test("starting another player pauses this one", () => {
  audio.paused = false
  controller.pauseForOther({ detail: { player: { id: "second" } } })
  assert.equal(audio.pauseCalls, 1)

  audio.paused = false
  controller.pauseForOther({ detail: { player: controller.element } })
  assert.equal(audio.pauseCalls, 1)
})

test("ending resets playback and playback errors are announced", () => {
  controller.ended()
  assert.equal(audio.currentTime, 0)
  assert.equal(controller.labelTarget.textContent, "Play")

  controller.failed()
  assert.equal(controller.errorTarget.hidden, false)
  assert.match(controller.errorTarget.textContent, /could not be played/)
})
