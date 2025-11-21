import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "category", "grid", "count", "noResults"]

  connect() {
    this.originalEvents = Array.from(this.gridTarget.children)
    this.updateCount()
  }

  filterEvents() {
    const searchTerm = this.searchTarget.value.toLowerCase().trim()
    const selectedCategory = this.categoryTarget.value
    
    let visibleCount = 0
    
    this.originalEvents.forEach(eventCard => {
      const title = eventCard.dataset.title || ""
      const location = eventCard.dataset.location || ""
      const category = eventCard.dataset.category || ""
      
      const matchesSearch = !searchTerm || 
        title.includes(searchTerm) || 
        location.includes(searchTerm)
      
      const matchesCategory = selectedCategory === "all" || 
        category === selectedCategory
      
      const shouldShow = matchesSearch && matchesCategory
      
      if (shouldShow) {
        eventCard.style.display = "block"
        visibleCount++
      } else {
        eventCard.style.display = "none"
      }
    })
    
    this.updateCount(visibleCount)
    this.toggleNoResults(visibleCount === 0)
  }

  updateCount(count = null) {
    const displayCount = count !== null ? count : this.originalEvents.length
    this.countTarget.textContent = `Showing ${displayCount} events`
  }

  toggleNoResults(show) {
    if (this.hasNoResultsTarget) {
      if (show) {
        this.noResultsTarget.classList.remove("hidden")
      } else {
        this.noResultsTarget.classList.add("hidden")
      }
    }
  }
}
