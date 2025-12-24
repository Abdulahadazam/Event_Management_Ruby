import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bookingForm", "registrationCard", "quantity", "displayQuantity", "totalAmount"]
  static values = { price: Number }

  connect() {
    this.updateTotal()
  }

  showBookingForm(event) {
    event.preventDefault()
    this.bookingFormTarget.classList.remove('hidden')
    this.registrationCardTarget.style.display = 'none'
  }

  cancelBooking(event) {
    event.preventDefault()
    this.bookingFormTarget.classList.add('hidden')
    this.registrationCardTarget.style.display = 'block'
  }

  decreaseQuantity(event) {
    event.preventDefault()
    const currentValue = parseInt(this.quantityTarget.value) || 1
    if (currentValue > 1) {
      this.quantityTarget.value = currentValue - 1
      this.updateTotal()
    }
  }

  increaseQuantity(event) {
    event.preventDefault()
    const currentValue = parseInt(this.quantityTarget.value) || 1
    if (currentValue < 10) {
      this.quantityTarget.value = currentValue + 1
      this.updateTotal()
    }
  }

  onQuantityChange() {
    this.updateTotal()
  }

  updateTotal() {
    const quantity = parseInt(this.quantityTarget.value) || 1
    if (this.hasDisplayQuantityTarget) {
      this.displayQuantityTarget.textContent = quantity
    }
    if (this.hasTotalAmountTarget) {
      this.totalAmountTarget.textContent = '$' + (this.priceValue * quantity).toFixed(2)
    }
  }

  async submitForm(event) {
    event.preventDefault()
    
    const form = event.target
    const formData = new FormData(form)
    const submitButton = form.querySelector('input[type="submit"]')
    
    submitButton.disabled = true
    submitButton.value = 'Processing...'
    
    try {
      const response = await fetch(form.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      
      const data = await response.json()
      
      if (data.url) {
        window.location.href = data.url
      } else if (data.error) {
        alert('Error: ' + data.error)
        submitButton.disabled = false
        submitButton.value = 'Proceed to Payment'
      }
    } catch (error) {
      console.error('Error:', error)
      alert('An error occurred. Please try again.')
      submitButton.disabled = false
      submitButton.value = 'Proceed to Payment'
    }
  }
}