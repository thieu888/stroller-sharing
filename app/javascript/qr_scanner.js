// QR Code Scanner functionality
class QRCodeScanner {
  constructor() {
    this.video = null;
    this.stream = null;
    this.scanning = false;
    this.canvas = null;
    this.context = null;
  }

  async startScanner(videoElement, canvasElement) {
    this.video = videoElement;
    this.canvas = canvasElement;
    this.context = this.canvas.getContext('2d');

    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ 
        video: { facingMode: 'environment' } 
      });
      this.video.srcObject = this.stream;
      this.video.play();
      this.scanning = true;
      this.scanLoop();
    } catch (error) {
      console.error('Erreur d\'accès à la caméra:', error);
      alert('Impossible d\'accéder à la caméra. Veuillez vérifier les permissions.');
    }
  }

  stopScanner() {
    this.scanning = false;
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop());
    }
    if (this.video) {
      this.video.srcObject = null;
    }
  }

  scanLoop() {
    if (!this.scanning) return;

    if (this.video.readyState === this.video.HAVE_ENOUGH_DATA) {
      this.canvas.width = this.video.videoWidth;
      this.canvas.height = this.video.videoHeight;
      this.context.drawImage(this.video, 0, 0, this.canvas.width, this.canvas.height);
      
      const imageData = this.context.getImageData(0, 0, this.canvas.width, this.canvas.height);
      
      // Ici on utiliserait une librairie comme jsQR pour décoder le QR code
      // Pour la démo, on simule la détection
      if (Math.random() < 0.01) { // 1% de chance de "détecter" un QR code
        this.onQRCodeDetected('STROLLER_' + Math.random().toString(36).substr(2, 9));
      }
    }

    requestAnimationFrame(() => this.scanLoop());
  }

  onQRCodeDetected(qrCode) {
    this.stopScanner();
    this.handleQRCode(qrCode);
  }

  async handleQRCode(qrCode) {
    try {
      const response = await fetch('/api/v1/strollers/scan', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ qr_code: qrCode })
      });

      const data = await response.json();
      
      if (data.success) {
        this.showStrollerInfo(data.data);
      } else {
        alert(data.message);
      }
    } catch (error) {
      console.error('Erreur lors du scan:', error);
      alert('Erreur lors du scan du QR code');
    }
  }

  showStrollerInfo(stroller) {
    const modalHtml = `
      <div class="modal fade" id="strollerInfoModal" tabindex="-1">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">Poussette trouvée !</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
              <div class="text-center mb-3">
                <i class="fas fa-baby-carriage fa-3x text-success"></i>
              </div>
              <h6>Code QR: ${stroller.qr_code}</h6>
              <p><strong>Batterie:</strong> ${stroller.battery_level}%</p>
              <p><strong>Station:</strong> ${stroller.station ? stroller.station.name : 'Aucune'}</p>
              <div class="progress mb-3">
                <div class="progress-bar bg-${stroller.battery_level > 20 ? 'success' : 'warning'}" 
                     style="width: ${stroller.battery_level}%"></div>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Annuler</button>
              <button type="button" class="btn btn-success" onclick="startRide(${stroller.id})">
                Démarrer le trajet
              </button>
            </div>
          </div>
        </div>
      </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    const modal = new bootstrap.Modal(document.getElementById('strollerInfoModal'));
    modal.show();
    
    // Nettoyer le modal quand il se ferme
    document.getElementById('strollerInfoModal').addEventListener('hidden.bs.modal', function() {
      this.remove();
    });
  }
}

// Fonction pour démarrer un trajet
async function startRide(strollerId) {
  try {
    const position = await getCurrentPosition();
    
    const response = await fetch('/api/v1/rides', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        stroller_id: strollerId,
        start_lat: position.coords.latitude,
        start_lng: position.coords.longitude
      })
    });

    const data = await response.json();
    
    if (data.success) {
      alert('Trajet démarré avec succès !');
      window.location.href = '/rides/' + data.data.id;
    } else {
      alert(data.message);
    }
  } catch (error) {
    console.error('Erreur lors du démarrage du trajet:', error);
    alert('Erreur lors du démarrage du trajet');
  }
}

// Fonction pour obtenir la position actuelle
function getCurrentPosition() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Géolocalisation non supportée'));
      return;
    }

    navigator.geolocation.getCurrentPosition(resolve, reject, {
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 60000
    });
  });
}

// Export global
window.QRCodeScanner = QRCodeScanner;
window.startRide = startRide;
window.getCurrentPosition = getCurrentPosition;
