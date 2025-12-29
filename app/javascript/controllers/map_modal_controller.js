import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "mapContainer"]
  
  connect() {
    // Create modal element
    this.createModal()
  }
  
  createModal() {
    const modal = document.createElement('div')
    modal.id = 'map-modal'
    modal.className = 'fixed inset-0 z-[9999] hidden items-center justify-center bg-black/80 backdrop-blur-sm'
    modal.innerHTML = `
      <div class="relative w-full h-full flex items-center justify-center p-4">
        <button
          id="map-close-button"
          class="absolute top-4 right-4 z-[10000] bg-white hover:bg-gray-100 text-gray-900 rounded-full p-3 shadow-lg transition-all hover:scale-110"
          aria-label="Close map"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M18 6 6 18"></path>
            <path d="M6 6l12 12"></path>
          </svg>
        </button>
        <div class="w-full h-full max-w-[95vw] max-h-[95vh] bg-white rounded-3xl shadow-2xl overflow-hidden">
          <div class="h-full" id="expanded-map-container"></div>
        </div>
      </div>
    `
    document.body.appendChild(modal)
    this.modalElement = modal

    // Add event listener directly to the close button
    const closeButton = modal.querySelector('#map-close-button')
    if (closeButton) {
      closeButton.addEventListener('click', (e) => {
        e.preventDefault()
        e.stopPropagation()
        this.close()
      })
    }

    // Also close when clicking the backdrop
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        this.close()
      }
    })
  }
  
  open(event) {
    if (event) event.stopPropagation()
    const mapElement = document.getElementById('event-map')
    if (!mapElement) return
    
    // Get data attributes from original map
    const lat = mapElement.dataset.eventMapLatitudeValue
    const lng = mapElement.dataset.eventMapLongitudeValue
    const location = mapElement.dataset.eventMapLocationValue
    const title = mapElement.dataset.eventMapTitleValue
    const zoom = mapElement.dataset.eventMapZoomValue
    const userLat = mapElement.dataset.eventMapUserLatitudeValue
    const userLng = mapElement.dataset.eventMapUserLongitudeValue
    
    const container = document.getElementById('expanded-map-container')
    container.innerHTML = '<div id="expanded-event-map" class="h-full w-full"></div>'
    
    // Show modal
    this.modalElement.classList.remove('hidden')
    this.modalElement.classList.add('flex')
    
    // Reinitialize map in modal after a short delay
    setTimeout(() => {
      this.reinitializeMap({
        dataset: {
          eventMapLatitudeValue: lat,
          eventMapLongitudeValue: lng,
          eventMapLocationValue: location,
          eventMapTitleValue: title,
          eventMapZoomValue: zoom,
          eventMapUserLatitudeValue: userLat,
          eventMapUserLongitudeValue: userLng
        }
      })
    }, 100)
  }
  
  close() {
    this.modalElement.classList.add('hidden')
    this.modalElement.classList.remove('flex')
  }
  
  reinitializeMap(mapData) {
    // Get data attributes
    const lat = parseFloat(mapData.dataset.eventMapLatitudeValue)
    const lng = parseFloat(mapData.dataset.eventMapLongitudeValue)
    const zoom = parseInt(mapData.dataset.eventMapZoomValue) || 15
    const location = mapData.dataset.eventMapLocationValue
    const title = mapData.dataset.eventMapTitleValue
    
    if (typeof window.L === 'undefined') {
      setTimeout(() => this.reinitializeMap(mapData), 100)
      return
    }
    
    const L = window.L
    
    const mapElement = document.getElementById('expanded-event-map')
    if (!mapElement) return
    
    // Remove existing map if any
    if (mapElement._leaflet_id) {
      mapElement._leaflet_id = null
    }
    
    // Initialize new map
    const map = L.map(mapElement, {
      center: [lat, lng],
      zoom: zoom,
      zoomControl: true,
      scrollWheelZoom: true
    })
    
    // Add tile layer
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19
    }).addTo(map)
    
    // Add event marker
    const eventIcon = L.icon({
      iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
      shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
      iconSize: [35, 57],
      iconAnchor: [17, 57],
      popupAnchor: [1, -34],
      shadowSize: [57, 57]
    })
    
    const eventMarker = L.marker([lat, lng], { icon: eventIcon })
      .addTo(map)
      .bindPopup(`
        <div class="p-3">
          <h3 class="font-bold text-gray-900 mb-1 text-lg">${title || 'Event Location'}</h3>
          <p class="text-sm text-gray-600">${location || ''}</p>
        </div>
      `)
      .openPopup()
    
    // Add user location and route if available
    const userLat = mapData.dataset.eventMapUserLatitudeValue
    const userLng = mapData.dataset.eventMapUserLongitudeValue
    
    if (userLat && userLng) {
      const userIcon = L.icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
        iconSize: [35, 57],
        iconAnchor: [17, 57],
        popupAnchor: [1, -34],
        shadowSize: [57, 57]
      })
      
      const userMarker = L.marker([parseFloat(userLat), parseFloat(userLng)], { icon: userIcon })
        .addTo(map)
        .bindPopup('<div class="p-2"><p class="font-semibold text-gray-900">Your Location</p></div>')
      
      // Get road route
      this.getRoadRoute(map, [parseFloat(userLat), parseFloat(userLng)], [lat, lng], eventMarker, userMarker)
    }
    
    // Invalidate size to ensure map renders correctly
    setTimeout(() => map.invalidateSize(), 200)
  }
  
  getRoadRoute(map, start, end, eventMarker, userMarker) {
    const osrmUrl = `https://router.project-osrm.org/route/v1/driving/${start[1]},${start[0]};${end[1]},${end[0]}?overview=full&geometries=geojson`
    
    fetch(osrmUrl)
      .then(response => response.json())
      .then(data => {
        if (data.code === 'Ok' && data.routes && data.routes.length > 0) {
          const route = data.routes[0]
          const coordinates = route.geometry.coordinates.map(coord => [coord[1], coord[0]])
          
          // Draw prominent orange route line on roads
          const routePolyline = L.polyline(coordinates, {
            color: '#f97316',
            weight: 8,
            opacity: 1,
            lineCap: 'round',
            lineJoin: 'round'
          }).addTo(map)
          
          // Add glow effect
          L.polyline(coordinates, {
            color: '#f97316',
            weight: 14,
            opacity: 0.4,
            lineCap: 'round',
            lineJoin: 'round'
          }).addTo(map)
          
          const distance = (route.distance / 1000).toFixed(1)
          const duration = Math.round(route.duration / 60)
          
          const midIndex = Math.floor(coordinates.length / 2)
          const midPoint = coordinates[midIndex]
          
          L.marker(midPoint, {
            icon: L.divIcon({
              className: 'postgis-route-label',
              html: `<div style="
                background: linear-gradient(135deg, #f97316, #ea580c);
                color: white;
                padding: 10px 16px;
                border-radius: 10px;
                font-size: 16px;
                font-weight: bold;
                white-space: nowrap;
                box-shadow: 0 6px 20px rgba(249, 115, 22, 0.6);
                border: 3px solid white;
              ">${distance} km • ${duration} min</div>`,
              iconSize: [0, 0]
            })
          }).addTo(map)
          
          const group = L.featureGroup([userMarker, eventMarker, routePolyline])
          map.fitBounds(group.getBounds().pad(0.2))
        }
      })
      .catch(error => {
        console.error('Routing error:', error)
      })
  }
}

