
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["physical", "remote"]

  connect() {
   
    const remoteRadio = this.element.querySelector('input[type="radio"][value="true"]')
    if (remoteRadio && remoteRadio.checked) {
      this.showRemote()
    } else {
      this.showPhysical()
    }
  }

  toggle(event) {
    const val = event.target.value
    if (val === "true") this.showRemote()
    else this.showPhysical()
  }

  showRemote() {
    this.remoteTarget.classList.remove("hidden")
    this.physicalTarget.classList.add("hidden")
  }

  showPhysical() {
    this.physicalTarget.classList.remove("hidden")
    this.remoteTarget.classList.add("hidden")
  }
}
