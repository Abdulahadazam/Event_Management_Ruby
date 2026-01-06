import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "indicator"]
  static values = { current: { type: Number, default: 0 } }

  connect() {
    this.showSlide(this.currentValue)
    this.startAutoPlay()
  }

  disconnect() {
    this.stopAutoPlay()
  }

  next() {
    this.currentValue = (this.currentValue + 1) % this.slideTargets.length
    this.showSlide(this.currentValue)
    this.resetAutoPlay()
  }

  previous() {
    this.currentValue = (this.currentValue - 1 + this.slideTargets.length) % this.slideTargets.length
    this.showSlide(this.currentValue)
    this.resetAutoPlay()
  }

  goToSlide(event) {
    this.currentValue = parseInt(event.currentTarget.dataset.index)
    this.showSlide(this.currentValue)
    this.resetAutoPlay()
  }

  showSlide(index) {
    this.slideTargets.forEach((slide, i) => {
      slide.classList.toggle("hidden", i !== index)
      slide.classList.toggle("opacity-0", i !== index)
      slide.classList.toggle("opacity-100", i === index)
    })
    
    this.indicatorTargets.forEach((indicator, i) => {
      indicator.classList.toggle("bg-white/50", i !== index)
      indicator.classList.toggle("bg-white", i === index)
    })
  }

  startAutoPlay() {
    this.autoPlayInterval = setInterval(() => {
      this.next()
    }, 5000) // Change slide every 5 seconds
  }

  stopAutoPlay() {
    if (this.autoPlayInterval) {
      clearInterval(this.autoPlayInterval)
    }
  }

  resetAutoPlay() {
    this.stopAutoPlay()
    this.startAutoPlay()
  }
}



