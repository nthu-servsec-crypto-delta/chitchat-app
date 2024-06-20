const $createPostitModal = document.getElementById("create-postit-modal");

window.onload = function() {
  if (location.hash) {
    const hash = location.hash.substring(1);
    const event_id = hash.split(':')[0];
    const [ lat, lng ] = hash.split(':')[1].split(',');
  
    // fill in the create postit form
    document.getElementById('event_id').value = event_id;
    document.getElementById('latitude').value = lat;
    document.getElementById('longitude').value = lng;
  
    const modal = bootstrap.Modal.getOrCreateInstance($createPostitModal);
    modal.show();
  
    // focus on the message input
    document.getElementById('message').focus();
  }
}