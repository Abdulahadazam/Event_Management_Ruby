
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["physical", "remote", "singleTicket", "multipleTickets"]

  connect() {

    const remoteRadio = this.element.querySelector('input[type="radio"][value="true"]')
    if (remoteRadio && remoteRadio.checked) {
      this.showRemote()
    } else {
      this.showPhysical()
    }

    
    const multipleTicketsRadio = this.element.querySelector('input[name="event_request[has_multiple_ticket_types]"][value="true"]')
    if (multipleTicketsRadio && multipleTicketsRadio.checked) {
      this.showMultipleTickets()
    } else {
      this.showSingleTicket()
    }
  }

  toggle(event) {
    const val = event.target.value
    if (val === "true") this.showRemote()
    else this.showPhysical()
  }

  toggleTicketTypes(event) {
    const val = event.target.value
    if (val === "true") {
      this.showMultipleTickets()
    } else {
      this.showSingleTicket()
    }
  }

  showRemote() {
    this.remoteTarget.classList.remove("hidden")
    this.physicalTarget.classList.add("hidden")
  }

  showPhysical() {
    this.physicalTarget.classList.remove("hidden")
    this.remoteTarget.classList.add("hidden")
  }

  showSingleTicket() {
    this.singleTicketTarget.classList.remove("hidden")
    this.multipleTicketsTarget.classList.add("hidden")
  }

  showMultipleTickets() {
    this.singleTicketTarget.classList.add("hidden")
    this.multipleTicketsTarget.classList.remove("hidden")
  }
}
