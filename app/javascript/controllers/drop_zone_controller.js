import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "label"]

  connect() {
    this.element.addEventListener("dragover", this.onDragOver.bind(this))
    this.element.addEventListener("dragleave", this.onDragLeave.bind(this))
    this.element.addEventListener("drop", this.onDrop.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("dragover", this.onDragOver.bind(this))
    this.element.removeEventListener("dragleave", this.onDragLeave.bind(this))
    this.element.removeEventListener("drop", this.onDrop.bind(this))
  }

  onDragOver(event) {
    event.preventDefault()
    this.element.classList.add("drop-zone--active")
  }

  onDragLeave() {
    this.element.classList.remove("drop-zone--active")
  }

  onDrop(event) {
    event.preventDefault()
    this.element.classList.remove("drop-zone--active")
    const file = event.dataTransfer.files[0]
    if (!file) return
    if (!file.name.endsWith(".zip")) {
      this.labelTarget.textContent = "Only .zip files are accepted."
      return
    }
    const dt = new DataTransfer()
    dt.items.add(file)
    this.inputTarget.files = dt.files
    this.labelTarget.textContent = file.name
  }
}
