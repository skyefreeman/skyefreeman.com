import { Controller } from "@hotwired/stimulus"

const MAX_FILE_SIZE = 20 * 1024 * 1024
const MP3_CONTENT_TYPES = ["audio/mpeg", "audio/mp3", "audio/x-mp3"]

export default class extends Controller {
  static targets = ["duration", "error", "feedback", "file", "progress", "status"]

  connect() {
    this.originalDuration = this.durationTarget.value
    this.ready = Boolean(this.originalDuration)
  }

  selected() {
    this.releaseMetadataReader()
    this.clearError()

    const file = this.fileTarget.files[0]
    if (!file) {
      this.restoreOriginalDuration()
      return
    }

    if (!file.name.toLowerCase().endsWith(".mp3") || !MP3_CONTENT_TYPES.includes(file.type)) {
      this.rejectFile("Choose an MP3 file.")
      return
    }

    if (file.size > MAX_FILE_SIZE) {
      this.rejectFile("Choose an MP3 that is 20 MiB or smaller.")
      return
    }

    this.ready = false
    this.durationTarget.value = ""
    this.feedbackTarget.hidden = false
    this.progressTarget.hidden = true
    this.statusTarget.textContent = "Reading audio duration…"
    this.setBusy(true)

    this.objectUrl = URL.createObjectURL(file)
    this.metadataAudio = new Audio()
    this.metadataAudio.preload = "metadata"
    this.metadataAudio.onloadedmetadata = () => this.metadataLoaded()
    this.metadataAudio.onerror = () => this.rejectFile("The selected MP3 could not be read.")
    this.metadataAudio.src = this.objectUrl
  }

  metadataLoaded() {
    const duration = this.metadataAudio.duration
    if (!Number.isFinite(duration) || duration <= 0) {
      this.rejectFile("The selected MP3 does not have a valid duration.")
      return
    }

    this.durationTarget.value = duration.toFixed(3)
    this.ready = true
    this.feedbackTarget.hidden = true
    this.statusTarget.textContent = ""
    this.setBusy(false)
    this.releaseMetadataReader()
  }

  validate(event) {
    if (this.ready) return

    event.preventDefault()
    this.showError("Wait for the MP3 duration to be read before saving.")
  }

  uploadStarted() {
    this.feedbackTarget.hidden = false
    this.progressTarget.hidden = false
    this.progressTarget.value = 0
    this.statusTarget.textContent = "Uploading… 0%"
    this.setBusy(true)
  }

  uploadProgress(event) {
    const progress = Math.round(event.detail.progress)
    this.progressTarget.value = progress
    this.statusTarget.textContent = `Uploading… ${progress}%`
  }

  uploadFailed(event) {
    event.preventDefault()
    this.feedbackTarget.hidden = true
    this.setBusy(false)
    this.showError(event.detail.error || "The MP3 could not be uploaded.")
  }

  uploadFinished() {
    this.progressTarget.value = 100
    this.statusTarget.textContent = "Upload complete. Saving audio sample…"
  }

  rejectFile(message) {
    this.fileTarget.value = ""
    this.restoreOriginalDuration()
    this.feedbackTarget.hidden = true
    this.setBusy(false)
    this.releaseMetadataReader()
    this.showError(message)
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
    this.errorTarget.focus()
  }

  clearError() {
    this.errorTarget.textContent = ""
    this.errorTarget.hidden = true
  }

  restoreOriginalDuration() {
    this.durationTarget.value = this.originalDuration
    this.ready = Boolean(this.originalDuration)
  }

  setBusy(busy) {
    this.element.setAttribute("aria-busy", String(busy))
    document.querySelectorAll(`[form="${this.element.id}"]`).forEach((button) => {
      button.disabled = busy
    })
  }

  releaseMetadataReader() {
    if (this.metadataAudio) {
      this.metadataAudio.onloadedmetadata = null
      this.metadataAudio.onerror = null
      this.metadataAudio.removeAttribute("src")
      this.metadataAudio.load()
      this.metadataAudio = null
    }
    if (this.objectUrl) {
      URL.revokeObjectURL(this.objectUrl)
      this.objectUrl = null
    }
  }

  disconnect() {
    this.releaseMetadataReader()
  }
}
