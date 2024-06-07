document.querySelector("#remove-co-organizer-form").addEventListener("click", function(ev) {
  if (!ev.target.matches("button, button > *")) return;

  let $button = ev.target.closest("button");
  let email = $button.dataset.email;

  let $form = $button.closest("form");
  $form.querySelector("input[name='email']").value = email;
});