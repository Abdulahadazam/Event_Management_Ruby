
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["physical", "remote", "singleTicket", "multipleTickets", "description", "aiButton", "buttonText", "aiStatus"]

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

  async generateDescription(event) {
    event.preventDefault()

    // Get form values
    const titleInput = this.element.querySelector('input[name="event_request[event_title]"]')
    const categorySelect = this.element.querySelector('select[name="event_request[category_id]"]')
    const capacityInput = this.element.querySelector('input[name="event_request[event_capacity]"]')

    const eventTitle = titleInput?.value?.trim()
    const categoryId = categorySelect?.value
    const capacity = capacityInput?.value

    // Validation
    if (!eventTitle) {
      this.showStatus("Please enter an event title first!", "error")
      titleInput?.focus()
      return
    }

    // Disable button and show loading state
    this.aiButtonTarget.disabled = true
    this.buttonTextTarget.textContent = "Generating..."
    this.showStatus("AI is writing your description...", "loading")

    try {
      const response = await fetch('/event_requests/generate_ai_description', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          event_title: eventTitle,
          category_id: categoryId,
          capacity: capacity
        })
      })

      const data = await response.json()

      if (data.description) {
        this.descriptionTarget.value = data.description
        this.showStatus("✓ Description generated successfully!", "success")
      } else if (data.error) {
        this.showStatus(`Error: ${data.error}`, "error")
      }
    } catch (error) {
      console.error('AI Generation Error:', error)
      this.showStatus("Failed to generate description. Please try again.", "error")
    } finally {
      // Re-enable button
      this.aiButtonTarget.disabled = false
      this.buttonTextTarget.textContent = "Ask AI to Write Description"

      // Clear status after 5 seconds
      setTimeout(() => {
        this.showStatus("", "")
      }, 5000)
    }
  }

  showStatus(message, type) {
    if (!this.hasAiStatusTarget) return

    this.aiStatusTarget.textContent = message

    // Apply color based on type
    this.aiStatusTarget.classList.remove('text-red-600', 'text-green-600', 'text-blue-600', 'text-gray-600')

    if (type === 'error') {
      this.aiStatusTarget.classList.add('text-red-600')
    } else if (type === 'success') {
      this.aiStatusTarget.classList.add('text-green-600')
    } else if (type === 'loading') {
      this.aiStatusTarget.classList.add('text-blue-600')
    } else {
      this.aiStatusTarget.classList.add('text-gray-600')
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
