import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["audio", "button", "error", "label"]

  toggle() {
    this.clearError()
    if (!this.hasAudioTarget) {
      this.failed()
      return
    }

    if (this.audioTarget.paused) {
      const playback = this.audioTarget.play()
      playback?.catch(() => this.failed())
    } else {
      this.audioTarget.pause()
    }
  }

  playing() {
    this.buttonTarget.setAttribute("aria-pressed", "true")
    this.buttonTarget.setAttribute("aria-label", this.buttonTarget.dataset.pauseLabel)
    this.labelTarget.textContent = "Pause"
    window.dispatchEvent(new CustomEvent("audio-player:started", { detail: { player: this.element } }))
  }

  paused() {
    this.showPlayState()
  }

  ended() {
    this.audioTarget.currentTime = 0
    this.showPlayState()
  }

  pauseForOther(event) {
    if (event.detail.player !== this.element && this.hasAudioTarget && !this.audioTarget.paused) {
      this.audioTarget.pause()
    }
  }

  failed() {
    if (this.hasAudioTarget && !this.audioTarget.paused) this.audioTarget.pause()
    this.showPlayState()
    this.errorTarget.textContent = "This audio sample could not be played."
    this.errorTarget.hidden = false
  }

  showPlayState() {
    this.buttonTarget.setAttribute("aria-pressed", "false")
    this.buttonTarget.setAttribute("aria-label", this.buttonTarget.dataset.playLabel)
    this.labelTarget.textContent = "Play"
  }

  clearError() {
    this.errorTarget.textContent = ""
    this.errorTarget.hidden = true
  }
}
