import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "capitalError", "lengthError", "sequentialError", "strength"]

  connect() {
    console.log("Password validation controller connected")
  }

  validate() {
    const password = this.passwordTarget.value
    
    
    const hasCapital = /^[A-Z]/.test(password)
    this.toggleError(this.capitalErrorTarget, !hasCapital)
    
  
    const hasMinLength = password.length >= 8
    this.toggleError(this.lengthErrorTarget, !hasMinLength)
    
    const hasSequential = /123|234|345|456|567|678|789|321|432|543|654|765|876|987/.test(password)
    this.toggleError(this.sequentialErrorTarget, hasSequential)
    
    this.updateStrength(password, hasCapital, hasMinLength, !hasSequential)
  }

  toggleError(element, showError) {
    if (showError) {
      element.classList.remove('hidden')
      element.classList.add('flex')
    } else {
      element.classList.add('hidden')
      element.classList.remove('flex')
    }
  }

  updateStrength(password, hasCapital, hasMinLength, noSequential) {
    if (password.length === 0) {
      this.strengthTarget.classList.add('hidden')
      return
    }

    this.strengthTarget.classList.remove('hidden')
    
    let strength = 0
    if (hasCapital) strength++
    if (hasMinLength) strength++
    if (noSequential) strength++
    if (password.length >= 12) strength++
    if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) strength++

    const strengthBar = this.strengthTarget.querySelector('.strength-bar')
    const strengthText = this.strengthTarget.querySelector('.strength-text')
    
    if (strength <= 2) {
      strengthBar.style.width = '33%'
      strengthBar.className = 'strength-bar h-2 bg-red-500 rounded-full transition-all duration-300'
      strengthText.textContent = 'Weak'
      strengthText.className = 'strength-text text-xs font-semibold text-red-600'
    } else if (strength <= 3) {
      strengthBar.style.width = '66%'
      strengthBar.className = 'strength-bar h-2 bg-yellow-500 rounded-full transition-all duration-300'
      strengthText.textContent = 'Medium'
      strengthText.className = 'strength-text text-xs font-semibold text-yellow-600'
    } else {
      strengthBar.style.width = '100%'
      strengthBar.className = 'strength-bar h-2 bg-green-500 rounded-full transition-all duration-300'
      strengthText.textContent = 'Strong'
      strengthText.className = 'strength-text text-xs font-semibold text-green-600'
    }
  }
}