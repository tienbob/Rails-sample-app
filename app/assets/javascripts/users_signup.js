// User Signup Form Validation
document.addEventListener('DOMContentLoaded', function() {
  
  // Bootstrap form validation
  (function() {
    'use strict';
    var forms = document.getElementsByClassName('needs-validation');
    var validation = Array.prototype.filter.call(forms, function(form) {
      form.addEventListener('submit', function(event) {
        if (form.checkValidity() === false) {
          event.preventDefault();
          event.stopPropagation();
        }
        form.classList.add('was-validated');
      }, false);
    });
  })();

  // Password confirmation validation
  const password = document.getElementById('user_password');
  const passwordConfirmation = document.getElementById('user_password_confirmation');
  
  function validatePasswordMatch() {
    if (password.value !== passwordConfirmation.value) {
      passwordConfirmation.setCustomValidity("Passwords don't match");
    } else {
      passwordConfirmation.setCustomValidity('');
    }
  }
  
  if (password && passwordConfirmation) {
    password.addEventListener('change', validatePasswordMatch);
    passwordConfirmation.addEventListener('keyup', validatePasswordMatch);
  }
});
