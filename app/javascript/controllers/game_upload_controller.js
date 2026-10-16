import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["feedback", "progress", "status", "error"]

  submit(event) {
    event.preventDefault()
    if (this.request) return

    const data = new FormData(this.element)
    const request = new XMLHttpRequest()
    this.request = request
    this.feedbackTarget.hidden = false
    this.errorTarget.hidden = true
    this.progressTarget.hidden = false
    this.progressTarget.value = 0
    this.statusTarget.textContent = "Uploading…"
    this.setBusy(true)

    request.upload.onprogress = (event) => {
      if (event.lengthComputable) {
        const percent = Math.round(event.loaded / event.total * 100)
        this.progressTarget.value = percent
        this.statusTarget.textContent = `Uploading… ${percent}%`
      } else {
        this.progressTarget.removeAttribute("value")
      }
    }
    request.upload.onload = () => {
      this.statusTarget.textContent = "Upload complete. Saving game…"
    }
    request.onload = () => this.complete(request)
    request.onerror = () => this.fail("Connection lost. Check your connection and the Games page before retrying; the game may have been saved.")
    request.ontimeout = () => this.fail("The upload timed out. Check the Games page before retrying; the game may have been saved.")
    request.onabort = () => this.fail("Upload cancelled. Your entries are still here.")
    request.open(this.element.method, this.element.action)
    request.setRequestHeader("Accept", "application/json")
    request.setRequestHeader("X-CSRF-Token", document.querySelector('meta[name="csrf-token"]').content)
    request.timeout = 600000
    request.send(data)
  }

  complete(request) {
    let response
    try { response = JSON.parse(request.responseText) } catch { response = {} }

    if (request.status >= 200 && request.status < 300 && response.location) {
      this.statusTarget.textContent = "Saved. Opening game…"
      window.location.assign(response.location)
    } else if (request.status === 413) {
      this.fail("The selected files exceed the server’s upload limit. Choose smaller files or ask the administrator to increase the limit.")
    } else if ([401, 403].includes(request.status) || new URL(request.responseURL, window.location.href).pathname === "/session/new") {
      this.fail("Your session has expired. Sign in in another tab, then retry. If it still fails, reload this page after copying your entries.")
    } else if (request.status === 422 && Array.isArray(response.errors)) {
      this.fail(response.errors.join(" "))
    } else if (request.status === 422) {
      this.fail("Your session could not be verified. Copy your entries, reload the page, and try again.")
    } else {
      this.fail("The server could not confirm the save. Your entries are still here. Check the Games page before retrying.")
    }
  }

  fail(message) {
    this.request = null
    this.setBusy(false)
    this.progressTarget.hidden = true
    this.statusTarget.textContent = ""
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
    this.errorTarget.focus()
  }

  setBusy(busy) {
    this.element.setAttribute("aria-busy", String(busy))
    Array.from(this.element.elements).filter((element) => element.type === "submit").forEach((button) => {
      button.disabled = busy
    })
  }

  disconnect() {
    if (this.request) {
      this.request.onabort = null
      this.request.abort()
      this.request = null
      this.setBusy(false)
    }
  }
}
