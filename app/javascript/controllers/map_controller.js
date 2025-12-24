import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number,
    zoom: { type: Number, default: 15 }
  }
  
  connect() {
    this.initializeMap()
  }
  
  initializeMap() {
    if (typeof L === 'undefined') return
    
    const map = L.map(this.element).setView(
      [this.latitudeValue, this.longitudeValue],
      this.zoomValue
    )
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors',
      maxZoom: 19
    }).addTo(map)
    
    L.marker([this.latitudeValue, this.longitudeValue])
      .addTo(map)
      .bindPopup('<b>Event Location</b>')
      .openPopup()
  }
}
