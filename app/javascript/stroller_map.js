// Configuration des cartes avec Leaflet
class StrollerMap {
  constructor(mapId, options = {}) {
    this.mapId = mapId;
    this.options = {
      center: [48.8566, 2.3522], // Paris par défaut
      zoom: 13,
      ...options
    };
    this.map = null;
    this.markers = [];
    this.init();
  }

  init() {
    const mapElement = document.getElementById(this.mapId);
    if (!mapElement) return;

    // Initialiser la carte
    this.map = L.map(this.mapId).setView(this.options.center, this.options.zoom);

    // Ajouter la couche de tuiles OpenStreetMap
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map);

    // Style personnalisé
    mapElement.style.borderRadius = '8px';
    mapElement.style.boxShadow = '0 4px 6px rgba(0, 0, 0, 0.1)';
  }

  // Ajouter une station avec ses poussettes
  addStation(station) {
    if (!this.map) return;

    const availableCount = station.available_strollers || 0;
    const totalCount = station.total_strollers || 0;
    
    // Couleur basée sur la disponibilité
    let color = '#dc3545'; // Rouge par défaut
    if (availableCount > 0) {
      const ratio = availableCount / Math.max(totalCount, 1);
      if (ratio > 0.5) color = '#28a745'; // Vert
      else if (ratio > 0.2) color = '#ffc107'; // Jaune
      else color = '#fd7e14'; // Orange
    }

    // Créer l'icône personnalisée
    const stationIcon = L.divIcon({
      className: 'custom-station-marker',
      html: `
        <div class="station-marker" style="background-color: ${color};">
          <i class="fas fa-baby-carriage text-white"></i>
          <span class="station-count">${availableCount}</span>
        </div>
      `,
      iconSize: [40, 40],
      iconAnchor: [20, 40],
      popupAnchor: [0, -40]
    });

    const marker = L.marker([station.lat, station.lng], { icon: stationIcon })
      .addTo(this.map);

    // Popup avec informations détaillées
    const popupContent = `
      <div class="station-popup">
        <h6 class="fw-bold mb-2">${station.name}</h6>
        <div class="d-flex justify-content-between mb-2">
          <span>Disponibles:</span>
          <span class="fw-bold text-success">${availableCount}</span>
        </div>
        <div class="d-flex justify-content-between mb-2">
          <span>Total:</span>
          <span class="fw-bold">${totalCount}</span>
        </div>
        <div class="d-flex justify-content-between mb-3">
          <span>Capacité:</span>
          <span class="fw-bold">${station.capacity}</span>
        </div>
        <div class="d-grid">
          <a href="/stations/${station.id}" class="btn btn-primary btn-sm">
            <i class="fas fa-eye me-1"></i>Voir détails
          </a>
        </div>
      </div>
    `;

    marker.bindPopup(popupContent);
    this.markers.push(marker);

    return marker;
  }

  // Ajouter une poussette individuelle
  addStroller(stroller) {
    if (!this.map) return;

    let color = '#6c757d'; // Gris par défaut
    let icon = 'fa-baby-carriage';
    
    switch (stroller.status) {
      case 'available':
        color = '#28a745';
        icon = 'fa-baby-carriage';
        break;
      case 'in_use':
        color = '#ffc107';
        icon = 'fa-user';
        break;
      case 'maintenance':
        color = '#dc3545';
        icon = 'fa-wrench';
        break;
      case 'cleaning':
        color = '#17a2b8';
        icon = 'fa-broom';
        break;
    }

    const strollerIcon = L.divIcon({
      className: 'custom-stroller-marker',
      html: `
        <div class="stroller-marker" style="background-color: ${color};">
          <i class="fas ${icon} text-white"></i>
        </div>
      `,
      iconSize: [30, 30],
      iconAnchor: [15, 30],
      popupAnchor: [0, -30]
    });

    const marker = L.marker([stroller.lat, stroller.lng], { icon: strollerIcon })
      .addTo(this.map);

    const popupContent = `
      <div class="stroller-popup">
        <h6 class="fw-bold mb-2">Poussette ${stroller.qr_code}</h6>
        <div class="d-flex justify-content-between mb-2">
          <span>Statut:</span>
          <span class="badge" style="background-color: ${color};">${stroller.status}</span>
        </div>
        ${stroller.battery_level ? `
          <div class="d-flex justify-content-between mb-2">
            <span>Batterie:</span>
            <span class="fw-bold">${stroller.battery_level}%</span>
          </div>
        ` : ''}
        <div class="d-grid">
          <a href="/strollers/${stroller.id}" class="btn btn-primary btn-sm">
            <i class="fas fa-eye me-1"></i>Voir détails
          </a>
        </div>
      </div>
    `;

    marker.bindPopup(popupContent);
    this.markers.push(marker);

    return marker;
  }

  // Centrer la carte sur les marqueurs
  fitBounds() {
    if (this.markers.length === 0) return;
    
    const group = new L.featureGroup(this.markers);
    this.map.fitBounds(group.getBounds().pad(0.1));
  }

  // Nettoyer les marqueurs
  clearMarkers() {
    this.markers.forEach(marker => this.map.removeLayer(marker));
    this.markers = [];
  }

  // Ajouter un contrôle de localisation
  addLocationControl() {
    if (!this.map) return;

    const locationButton = L.control({ position: 'topright' });
    locationButton.onAdd = () => {
      const div = L.DomUtil.create('div', 'leaflet-bar leaflet-control leaflet-control-custom');
      div.innerHTML = '<i class="fas fa-location-arrow"></i>';
      div.style.backgroundColor = 'white';
      div.style.backgroundSize = '30px 30px';
      div.style.width = '30px';
      div.style.height = '30px';
      div.style.cursor = 'pointer';
      div.style.display = 'flex';
      div.style.alignItems = 'center';
      div.style.justifyContent = 'center';
      div.title = 'Ma position';

      div.onclick = () => {
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition((position) => {
            const { latitude, longitude } = position.coords;
            this.map.setView([latitude, longitude], 15);
            
            // Ajouter un marqueur temporaire pour la position de l'utilisateur
            const userIcon = L.divIcon({
              className: 'user-location-marker',
              html: '<div class="user-marker"><i class="fas fa-user text-primary"></i></div>',
              iconSize: [25, 25],
              iconAnchor: [12.5, 25]
            });
            
            L.marker([latitude, longitude], { icon: userIcon })
              .addTo(this.map)
              .bindPopup('Votre position')
              .openPopup();
          });
        }
      };
      
      return div;
    };
    
    locationButton.addTo(this.map);
  }
}

// Styles CSS pour les marqueurs personnalisés
const mapStyles = `
  <style>
    .custom-station-marker, .custom-stroller-marker {
      background: transparent !important;
      border: none !important;
    }
    
    .station-marker {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
      border: 3px solid white;
      box-shadow: 0 2px 4px rgba(0,0,0,0.3);
    }
    
    .station-marker i {
      font-size: 14px;
    }
    
    .station-count {
      position: absolute;
      top: -8px;
      right: -8px;
      background: #ff4444;
      color: white;
      border-radius: 50%;
      width: 20px;
      height: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
      font-weight: bold;
      border: 2px solid white;
    }
    
    .stroller-marker {
      width: 30px;
      height: 30px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 2px solid white;
      box-shadow: 0 2px 4px rgba(0,0,0,0.3);
    }
    
    .stroller-marker i {
      font-size: 12px;
    }
    
    .user-marker {
      width: 25px;
      height: 25px;
      background: white;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 2px solid #007bff;
      box-shadow: 0 2px 4px rgba(0,0,0,0.3);
    }
    
    .station-popup, .stroller-popup {
      min-width: 200px;
    }
    
    .leaflet-popup-content-wrapper {
      border-radius: 8px;
    }
    
    .leaflet-popup-tip {
      background: white;
    }
  </style>
`;

// Injecter les styles
document.head.insertAdjacentHTML('beforeend', mapStyles);

// Exporter pour usage global
window.StrollerMap = StrollerMap;
