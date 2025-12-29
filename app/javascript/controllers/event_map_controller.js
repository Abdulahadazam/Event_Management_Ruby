import { Controller } from "@hotwired/stimulus"

// Leaflet is loaded via CDN in the layout
// Wait for it to be available

export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number,
    location: String,
    title: String,
    zoom: { type: Number, default: 15 },
    userLatitude: Number,
    userLongitude: Number
  }

  connect() {
    this.initializeMap()
  }

  initializeMap() {
    // Wait for Leaflet to be available (loaded via CDN)
    if (typeof window.L === 'undefined') {
      setTimeout(() => this.initializeMap(), 100)
      return
    }

    const L = window.L

    // Fix for default marker icon issue in Leaflet
    delete L.Icon.Default.prototype._getIconUrl;
    L.Icon.Default.mergeOptions({
      iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
      iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
      shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
    });

    const center = [this.latitudeValue, this.longitudeValue]
    const zoom = this.zoomValue

    // Initialize map
    this.map = L.map(this.element, {
      center: center,
      zoom: zoom,
      zoomControl: true,
      scrollWheelZoom: true
    })

    // Add tile layer
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19
    }).addTo(this.map)

    // Add event marker with custom icon
    const eventIcon = L.icon({
      iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
      shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    })

    // Store route polyline for later use
    this.routePolyline = null

    // Event marker
    const eventMarker = L.marker(center, { icon: eventIcon })
      .addTo(this.map)
      .bindPopup(`
        <div class="p-2">
          <h3 class="font-bold text-gray-900 mb-1">${this.titleValue || 'Event Location'}</h3>
          <p class="text-sm text-gray-600">${this.locationValue || ''}</p>
          <div class="mt-2 pt-2 border-t border-gray-200">
            <p class="text-xs text-orange-600 font-semibold">📍 PostGIS Location</p>
          </div>
        </div>
      `)
      .openPopup()
    
    // Store event marker for later use
    this.eventMarker = eventMarker

    // Add user location marker if available and get road route
    if (this.hasUserLatitudeValue && this.hasUserLongitudeValue) {
      const userIcon = L.icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
        iconSize: [30, 46],
        iconAnchor: [15, 46],
        popupAnchor: [1, -34],
        shadowSize: [46, 46]
      })

      this.userMarker = L.marker(
        [this.userLatitudeValue, this.userLongitudeValue],
        { icon: userIcon }
      )
        .addTo(this.map)
        .bindPopup('<div class="p-2"><p class="font-semibold text-gray-900">Your Location</p></div>')

      // Get road route using OSRM API
      this.getRoadRoute(
        [this.userLatitudeValue, this.userLongitudeValue],
        [this.latitudeValue, this.longitudeValue]
      )
    } else {
      // If no user location, just show event location
      this.map.setView(center, zoom)
    }

    // Real-time location updates (if geolocation is available)
    if (navigator.geolocation) {
      this.watchId = navigator.geolocation.watchPosition(
        (position) => this.updateUserLocation(position),
        (error) => console.log('Geolocation error:', error),
        {
          enableHighAccuracy: true,
          timeout: 5000,
          maximumAge: 0
        }
      )
    }
  }

  getRoadRoute(start, end) {
    // Use OSRM (Open Source Routing Machine) API for road routing
    const osrmUrl = `https://router.project-osrm.org/route/v1/driving/${start[1]},${start[0]};${end[1]},${end[0]}?overview=full&geometries=geojson`
    
    fetch(osrmUrl)
      .then(response => response.json())
      .then(data => {
        if (data.code === 'Ok' && data.routes && data.routes.length > 0) {
          const route = data.routes[0]
          const coordinates = route.geometry.coordinates.map(coord => [coord[1], coord[0]]) // Convert [lng, lat] to [lat, lng]
          
          // Remove existing route if any
          if (this.routePolyline) {
            this.map.removeLayer(this.routePolyline)
          }
          
          // Draw prominent orange route line on roads
          this.routePolyline = L.polyline(coordinates, {
            color: '#f97316', // Orange
            weight: 6,
            opacity: 0.9,
            lineCap: 'round',
            lineJoin: 'round'
          }).addTo(this.map)
          
          // Add shadow/glow effect
          L.polyline(coordinates, {
            color: '#f97316',
            weight: 10,
            opacity: 0.3,
            lineCap: 'round',
            lineJoin: 'round'
          }).addTo(this.map)
          
          // Calculate distance
          const distance = (route.distance / 1000).toFixed(1) // Convert to km
          const duration = Math.round(route.duration / 60) // Convert to minutes
          
          // Add distance label at midpoint
          const midIndex = Math.floor(coordinates.length / 2)
          const midPoint = coordinates[midIndex]
          
          L.marker(midPoint, {
            icon: L.divIcon({
              className: 'postgis-route-label',
              html: `<div style="
                background: linear-gradient(135deg, #f97316, #ea580c);
                color: white;
                padding: 8px 14px;
                border-radius: 8px;
                font-size: 13px;
                font-weight: bold;
                white-space: nowrap;
                box-shadow: 0 4px 12px rgba(249, 115, 22, 0.5);
                border: 2px solid white;
              ">${distance} km • ${duration} min</div>`,
              iconSize: [0, 0]
            })
          }).addTo(this.map)
          
          // Fit map to show route
          const group = L.featureGroup([this.userMarker, this.eventMarker, this.routePolyline])
          this.map.fitBounds(group.getBounds().pad(0.2))
        } else {
          // Fallback to straight line if routing fails
          this.drawStraightLine(start, end)
        }
      })
      .catch(error => {
        console.error('Routing error:', error)
        // Fallback to straight line
        this.drawStraightLine(start, end)
      })
  }
  
  drawStraightLine(start, end) {
    // Fallback: draw straight orange line
    this.routePolyline = L.polyline([start, end], {
      color: '#f97316',
      weight: 6,
      opacity: 0.9
    }).addTo(this.map)
    
    const group = L.featureGroup([this.userMarker, this.eventMarker, this.routePolyline])
    this.map.fitBounds(group.getBounds().pad(0.2))
  }

  updateUserLocation(position) {
    if (!this.map) return

    const lat = position.coords.latitude
    const lng = position.coords.longitude

    // Update user marker position
    if (this.userMarker) {
      this.userMarker.setLatLng([lat, lng])
      
      // Update route if event location is available
      if (this.latitudeValue && this.longitudeValue) {
        this.getRoadRoute([lat, lng], [this.latitudeValue, this.longitudeValue])
      }
    }
  }
  
  expandMap() {
    // This will be called when map is clicked
    if (this.map) {
      this.map.invalidateSize()
    }
  }

  disconnect() {
    if (this.watchId) {
      navigator.geolocation.clearWatch(this.watchId)
    }
    if (this.map) {
      this.map.remove()
    }
  }
}

