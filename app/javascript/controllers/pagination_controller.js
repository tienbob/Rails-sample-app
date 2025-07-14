// Enhanced Pagination JavaScript for Hotwire/Stimulus
// Move this file to app/javascript/controllers/pagination_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Add loading states to pagination links
    const paginationLinks = document.querySelectorAll('.pagination a');
    paginationLinks.forEach(link => {
      link.addEventListener('click', function(e) {
        const pagination = this.closest('.pagination');
        if (pagination) {
          pagination.classList.add('pagination-loading');
        }
        this.style.opacity = '0.6';
        this.style.pointerEvents = 'none';
        // Optional: Show loading spinner
        // const spinner = document.createElement('div');
        // spinner.className = 'spinner-border spinner-border-sm ms-2';
        // spinner.setAttribute('role', 'status');
        // this.appendChild(spinner);
      });
    });

    // Smooth scroll to top when pagination is clicked
    paginationLinks.forEach(link => {
      link.addEventListener('click', function(e) {
        setTimeout(() => {
          const feedContainer = document.querySelector('.feed-container') || document.querySelector('.microposts-container');
          if (feedContainer) {
            feedContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }
        }, 100);
      });
    });

    // Keyboard navigation for pagination
    document.addEventListener('keydown', function(e) {
      if (e.target.tagName.toLowerCase() === 'input' || e.target.tagName.toLowerCase() === 'textarea') {
        return;
      }
      const currentPage = document.querySelector('.pagination .current');
      if (!currentPage) return;
      if (e.key === 'ArrowLeft' || e.key === 'h') {
        const prevLink = document.querySelector('.pagination .prev_page');
        if (prevLink && !prevLink.classList.contains('disabled')) {
          e.preventDefault();
          prevLink.click();
        }
      } else if (e.key === 'ArrowRight' || e.key === 'l') {
        const nextLink = document.querySelector('.pagination .next_page');
        if (nextLink && !nextLink.classList.contains('disabled')) {
          e.preventDefault();
          nextLink.click();
        }
      }
    });

    // Add tooltips to pagination buttons
    const paginationItems = document.querySelectorAll('.pagination a, .pagination span');
    paginationItems.forEach(item => {
      if (item.classList.contains('prev_page')) {
        item.setAttribute('title', 'Go to previous page (← or H)');
      } else if (item.classList.contains('next_page')) {
        item.setAttribute('title', 'Go to next page (→ or L)');
      } else if (item.classList.contains('current')) {
        item.setAttribute('title', 'Current page');
      } else if (!item.classList.contains('gap')) {
        item.setAttribute('title', `Go to page ${item.textContent}`);
      }
    });

    // Add page transition effects
    const style = document.createElement('style');
    style.textContent = `
      .feed-container,
      .microposts-container {
        transition: opacity 0.3s ease-in-out;
      }
      .pagination-loading .feed-container,
      .pagination-loading .microposts-container {
        opacity: 0.7;
      }
    `;
    document.head.appendChild(style);
  }
}
