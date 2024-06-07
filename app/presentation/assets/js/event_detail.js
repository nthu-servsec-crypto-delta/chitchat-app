document.querySelector("#remove-co-organizer-form").addEventListener("click", function(ev) {
  if (!ev.target.matches("button, button > *")) return;

  let $button = ev.target.closest("button");
  let email = $button.dataset.email;

  let $form = $button.closest("form");
  $form.querySelector("input[name='email']").value = email;
});

document.querySelector("#applicants-form").addEventListener("click", function(ev) {
  if (!ev.target.matches("button, button > *")) return;

  let $button = ev.target.closest("button");

  let action = "";
  if ($button.classList.contains("btn-success")) {
    action = "approve";
  } else if ($button.classList.contains("btn-danger")) {
    action = "reject";
  }

  if (action === "") {
    ev.preventDefault();
    return;
  }

  let email = $button.dataset.email;
  let $form = $button.closest("form");

  $form.querySelector("input[name='action']").value = action;
  $form.querySelector("input[name='email']").value = email;
});