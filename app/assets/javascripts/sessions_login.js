// filepath: d:\Learn Ruby\sample_app\app\assets\javascripts\sessions_login.js

document.addEventListener('DOMContentLoaded', function() {
  // Password toggle functionality
  const togglePassword = document.getElementById('togglePassword');
  const passwordField = document.querySelector('input[type="password"]');
  
  if (togglePassword && passwordField) {
    togglePassword.addEventListener('click', function() {
      const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
      passwordField.setAttribute('type', type);
      
      const icon = this.querySelector('i');
      icon.classList.toggle('fa-eye');
      icon.classList.toggle('fa-eye-slash');
    });
  }
  
  // Form submission loading state
  const loginForm = document.querySelector('.login-form');
  const loginButton = document.querySelector('.btn-login');
  
  if (loginForm && loginButton) {
    loginForm.addEventListener('submit', function() {
      loginButton.classList.add('loading');
      loginButton.textContent = 'Signing In...';
    });
  }
  
  // Input focus animations
  const inputs = document.querySelectorAll('.form-input');
  inputs.forEach(input => {
    input.addEventListener('focus', function() {
      this.parentElement.classList.add('focused');
    });
    
    input.addEventListener('blur', function() {
      if (!this.value) {
        this.parentElement.classList.remove('focused');
      }
    });
    
    // Check if input has value on page load
    if (input.value) {
      input.parentElement.classList.add('focused');
    }
  });
  
  // Auto-dismiss alerts
  const alerts = document.querySelectorAll('.alert');
  alerts.forEach(alert => {
    setTimeout(() => {
      alert.style.animation = 'fadeOut 0.5s ease-out forwards';
      setTimeout(() => {
        alert.remove();
      }, 500);
    }, 5000);
  });
});

// Fade out animation
const fadeOutKeyframes = `
  @keyframes fadeOut {
    from { opacity: 1; transform: translateY(0); }
    to { opacity: 0; transform: translateY(-10px); }
  }
`;

// Add the keyframes to the document
const style = document.createElement('style');
style.textContent = fadeOutKeyframes;
document.head.appendChild(style);