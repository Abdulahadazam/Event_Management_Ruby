import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "error"]

  validate() {
    const email = this.emailTarget.value
    const isValid = this.isValidEmail(email)
    
    if (email.length > 0 && !isValid) {
      this.errorTarget.classList.remove('hidden')
      this.emailTarget.classList.add('border-red-500')
      this.emailTarget.classList.remove('border-gray-300')
    } else {
      this.errorTarget.classList.add('hidden')
      this.emailTarget.classList.remove('border-red-500')
      this.emailTarget.classList.add('border-gray-300')
    }
  }

  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }
}