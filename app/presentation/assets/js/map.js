const username = document.querySelector("nav a[data-username]").dataset.username;

const $map = document.getElementById('map');
const $locationErrorToast = document.getElementById('locationErrorToast');

const mapEvent = {
  id: $map.dataset.id,
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
L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 20,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);

const createPostitPopup = L.popup();

map.on('click', function(e) {
  if (e.latlng.distanceTo(mapEvent.location) > mapEvent.radius) return;

  createPostitPopup.setLatLng(e.latlng)
                   .setContent(`<a href="/postits#${mapEvent.id}:${e.latlng.lat.toFixed(6)},${e.latlng.lng.toFixed(6)}" target="_blank">Create a new postit here</a>`)
                   .openOn(map);
});

const eventMarker = L.marker(mapEvent.location, { title: mapEvent.name }).addTo(map);
const eventPopup = eventMarker.bindPopup(`<b>${mapEvent.name}</b>`).openPopup();

const eventRange = L.circle(mapEvent.location, {
  color: 'red',
  fillColor: '#f03',
  fillOpacity: 0.1,
  radius: mapEvent.radius
}).addTo(map);

const locationOptions = {
  enableHighAccuracy: true,
  timeout: 5000,
  maximumAge: 0
};

let coords = null;

function getCurrentLocation() {
  return new Promise((resolve, reject) => {
    function onLocationSuccess(e) {
      resolve(e.coords);
    }
    
    function onLocationError(e) {
      reject(e);
    }

    navigator.geolocation.getCurrentPosition(onLocationSuccess, onLocationError, locationOptions);
  });
}

L.Control.CurrentLocation = L.Control.extend({
  onAdd: function(map) {
    const container = L.DomUtil.create('button', 'btn btn-light btn-lg');
    container.innerHTML = '<i class="bi bi-crosshair2"></i>';
    container.title = 'Go To Current Location';

    container.onclick = async function() {
      // move first
      if (coords) map.setView([coords.latitude, coords.longitude]);

      await updateLocation();
      map.setView([coords.latitude, coords.longitude]);
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
const currentLocationIcon = L.divIcon({ className: 'current-location-icon', iconSize: [20, 20], bgPos: [10, 10] });
const currentLocationMarker = L.marker([0, 0], { icon: currentLocationIcon, zIndexOffset: 1000 }).addTo(map);

(async () => {
  await updateLocation();
})();

setInterval(async () => {
  console.log('Updating current location marker...');
  await updateLocation();
}, locationOptions.timeout);

async function sendLocation(coords) {
  try {
    const formData = new FormData();
    formData.append('latitude', coords.latitude);
    formData.append('longitude', coords.longitude);

    let response = await fetch(`/events/${mapEvent.id}/location`, {
      method: 'POST',
      body: formData
    });

    let accounts = await response.json();

    return accounts;
  } catch (error) {
    console.error(error);
  }
}

// postit marker
const postitsLayer = L.layerGroup().addTo(map);
const postitIcon = L.divIcon({ className: 'postit-icon', html: `<i class="bi bi-sticky-fill"></i>`, iconSize: [30, 30], bgPos: [15, 15] });

const postits = document.querySelectorAll('ul#postits_data li');
postits?.forEach(postit => {
  const lat = postit.dataset.lat;
  const lng = postit.dataset.lng;
  const postitMarker = L.marker([lat, lng], { icon: postitIcon }).addTo(postitsLayer);
  postitMarker.bindPopup(`${postit.dataset.message}`, { autoClose: false });
});

// account marker
const accountsLayer = L.layerGroup().addTo(map);
const accountIcon = L.divIcon({ className: 'account-icon', html: `<i class="bi bi-person-fill"></i>`, iconSize: [30, 30], bgPos: [15, 15] });

async function updateLocation() {
  try {
    coords = await getCurrentLocation();
    currentLocationMarker.setLatLng([coords.latitude, coords.longitude]);
  } catch (error) {
    console.error(error);
    const toast = bootstrap.Toast.getOrCreateInstance($locationErrorToast);
    toast.show();
  }

  let accounts = await sendLocation(coords);
  accountsLayer.clearLayers();
  accounts.forEach(data => {
    const account = data.attributes;
    if (account.username === username) return;

    const accountMarker = L.marker([account.location.latitude, account.location.longitude], { icon: accountIcon }).addTo(accountsLayer);
    accountMarker.bindPopup(`<a href="/account/${account.username}" target="_blank">${account.username}</a>`, { autoClose: false });
  });
}
