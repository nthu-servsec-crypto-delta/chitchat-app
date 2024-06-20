const $map = document.getElementById('map');
const mapEvent = {
  name: $map.dataset.name,
  radius: $map.dataset.radius,
  _location: {
    lat: $map.dataset.lat,
    lng: $map.dataset.lng
  },
  get location() {
    return [this._location.lat, this._location.lng];
  }
}

const map = L.map('map').setView(mapEvent.location, 16);
const eventRange = L.circle(mapEvent.location, {
  color: 'red',
  fillColor: '#f03',
  fillOpacity: 0.1,
  radius: mapEvent.radius
}).addTo(map);

const eventMarker = L.marker(mapEvent.location, { title: mapEvent.name }).addTo(map);
const eventPopup = eventMarker.bindPopup(`<b>${mapEvent.name}</b>`);
eventMarker.on('click', () => {
  eventPopup.openPopup();
});

L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 20,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);

const locationOptions = {
  enableHighAccuracy: true,
  timeout: 5000,
  maximumAge: 0
};
let coords = null;

function onLocationSuccess(e) {
  coords = e.coords;
  map.setView([e.coords.latitude, e.coords.longitude], 16);
  currentLocationMarker.setLatLng([coords.latitude, coords.longitude]);
}

function onLocationError(e) {
  // trigger bootstrap toast
  const toast = bootstrap.Toast.getOrCreateInstance(document.getElementById('locationErrorToast'));
  toast.show();
}

L.Control.CurrentLocation = L.Control.extend({
  onAdd: function(map) {
    const container = L.DomUtil.create('button', 'btn btn-light btn-lg');
    container.innerHTML = '<i class="bi bi-crosshair2"></i>';
    container.title = 'Go To Current Location';

    container.onclick = function() {
      // move first
      console.log('click')
      if (coords) map.setView([coords.latitude, coords.longitude]);
      navigator.geolocation.getCurrentPosition(onLocationSuccess, onLocationError, locationOptions);
    }

    return container;
  }
});
L.control.currentLocation = function(opts) { return new L.Control.CurrentLocation(opts); }
L.control.currentLocation({ position: 'bottomright' }).addTo(map);

L.Control.CurrentEvent = L.Control.extend({
  onAdd: function(map) {
    const container = L.DomUtil.create('button', 'btn btn-light btn-lg');
    container.innerHTML = '<i class="bi bi-geo-alt-fill"></i>';
    container.title = 'Go Back To Event';

    container.onclick = function() {
      map.setView(mapEvent.location);
    }

    return container;
  }
});
L.control.currentEvent = function(opts) { return new L.Control.CurrentEvent(opts); }
L.control.currentEvent({ position: 'bottomright' }).addTo(map);

// current location marker
const $currentLocationIcon = L.divIcon({ className: 'current-location-icon', iconSize: [20, 20], bgPos: [8, 8] });
const currentLocationMarker = L.marker([0, 0], { icon: $currentLocationIcon }).addTo(map);

navigator.geolocation.getCurrentPosition(onLocationSuccess, onLocationError, locationOptions);

// setInterval(() => {
//   console.log('Updating current location marker...');
//   navigator.geolocation.getCurrentPosition(onLocationSuccess, onLocationError, locationOptions);
// }, locationOptions.timeout);