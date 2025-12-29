import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "totalAmount", "submitButton", "errorMessage", "ticketType", "pricePerTicket"]
  static values = { 
    price: Number, 
    eventId: Number
  }

  connect() {
    this.ticketTypes = {
      'Standard': this.priceValue,
      'VIP': this.priceValue * 1.5,
      'Premium': this.priceValue * 2.0
    }
    this.updateTotal()
  }

  onTicketTypeChange(event) {
    this.updateTotal()
  }

  increaseQuantity() {
    const current = parseInt(this.quantityTarget.value) || 1
    if (current < 10) {
      this.quantityTarget.value = current + 1
      this.updateTotal()
    }
  }

  decreaseQuantity() {
    const current = parseInt(this.quantityTarget.value) || 1
    if (current > 1) {
      this.quantityTarget.value = current - 1
      this.updateTotal()
    }
  }

  onQuantityChange() {
    const value = parseInt(this.quantityTarget.value) || 1
    if (value < 1) {
      this.quantityTarget.value = 1
    } else if (value > 10) {
      this.quantityTarget.value = 10
    }
    this.updateTotal()
  }

  updateTotal() {
    const quantity = parseInt(this.quantityTarget.value) || 1
    const selectedType = this.getSelectedTicketType()
    const ticketPrice = this.ticketTypes[selectedType] || this.priceValue
    const total = (ticketPrice * quantity).toFixed(2)
    
    if (this.hasPricePerTicketTarget) {
      this.pricePerTicketTarget.textContent = `$${ticketPrice.toFixed(2)}`
    }
    this.totalAmountTarget.textContent = `$${total}`
  }

  getSelectedTicketType() {
    const selected = this.ticketTypeTargets.find(target => target.checked)
    return selected ? selected.value : 'Standard'
  }

  async submitForm(event) {
    event.preventDefault()
    
    const quantity = parseInt(this.quantityTarget.value) || 1
    const ticketType = this.getSelectedTicketType()
    
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = "Processing..."
    this.errorMessageTarget.classList.add("hidden")

    try {
      const response = await fetch(`/events/${this.eventIdValue}/tickets`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ 
          quantity: quantity,
          ticket_type: ticketType
        })
      })

      const data = await response.json()

      if (response.ok && data.url) {
        window.location.href = data.url
      } else {
        // Backend returns error - display it to user
        if (data.requires_registration) {
          // Show registration required message with link to event page
          this.showRegistrationRequiredMessage(data.error, data.event_url)
        } else {
          // Other errors
          throw new Error(data.error || 'Payment processing failed')
        }
      }
    } catch (error) {
      // Display error message from backend
      if (this.hasErrorMessageTarget) {
        const errorText = this.errorMessageTarget.querySelector('p')
        if (errorText) {
          errorText.textContent = error.message
        } else {
          this.errorMessageTarget.textContent = error.message
        }
        this.errorMessageTarget.classList.remove("hidden")
      }
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.textContent = "Proceed to Payment"
    }
  }
  
  showRegistrationRequiredMessage(message, eventUrl) {
    // Show toast notification with backend's error message
    const alertMessage = `
      <div class="fixed top-4 right-4 z-50 max-w-md animate-slide-in">
        <div class="bg-gradient-to-r from-amber-50 to-orange-50 border-2 border-amber-400 rounded-xl shadow-2xl p-5">
          <div class="flex items-start gap-4">
            <div class="w-10 h-10 bg-amber-500 rounded-full flex items-center justify-center text-white flex-shrink-0">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 9v4"></path>
                <path d="M12 17h.01"></path>
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
              </svg>
            </div>
            <div class="flex-1">
              <h3 class="font-bold text-amber-900 text-lg mb-1">Registration Required</h3>
              <p class="text-amber-800 text-sm mb-3">${message}</p>
              <a href="${eventUrl}" class="inline-block px-4 py-2 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white rounded-lg font-semibold text-sm transition-all">
                Go to Event Page
              </a>
            </div>
            <button onclick="this.closest('.animate-slide-in').remove()" class="text-amber-600 hover:text-amber-800">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M18 6L6 18"></path>
                <path d="M6 6l12 12"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>
    `
    
    // Remove any existing alerts
    const existingAlert = document.querySelector('.animate-slide-in')
    if (existingAlert) {
      existingAlert.remove()
    }
    
    // Add new alert
    document.body.insertAdjacentHTML('beforeend', alertMessage)
    
    // Auto-remove after 8 seconds
    setTimeout(() => {
      const alert = document.querySelector('.animate-slide-in')
      if (alert) {
        alert.style.animation = 'slide-out 0.3s ease-out forwards'
        setTimeout(() => alert.remove(), 300)
      }
    }, 8000)
    
    // Reset button
    this.submitButtonTarget.disabled = false
    this.submitButtonTarget.textContent = "Proceed to Payment"
  }
}

