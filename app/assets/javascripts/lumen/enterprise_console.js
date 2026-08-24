//= require chart

(function() {
  function initializeEnterpriseNavigation() {
    var body = document.querySelector('body.enterprise-console');
    var toggle = document.querySelector('.enterprise-menu-toggle');
    var scrim = document.querySelector('.enterprise-sidebar-scrim');

    if (!body || !toggle || !scrim || toggle.dataset.enterpriseReady) return;

    toggle.dataset.enterpriseReady = 'true';

    function closeNavigation() {
      body.classList.remove('sidebar-open');
      toggle.setAttribute('aria-expanded', 'false');
    }

    toggle.addEventListener('click', function() {
      var opening = !body.classList.contains('sidebar-open');
      body.classList.toggle('sidebar-open', opening);
      toggle.setAttribute('aria-expanded', opening ? 'true' : 'false');
    });

    scrim.addEventListener('click', closeNavigation);
    document.addEventListener('keydown', function(event) {
      if (event.key === 'Escape') closeNavigation();
    });
  }

  function initializeEnterpriseChart() {
    var canvas = document.getElementById('enterprise-activity-chart');

    if (!canvas || typeof Chart === 'undefined' || canvas.dataset.chartReady) return;

    canvas.dataset.chartReady = 'true';

    var labels = JSON.parse(canvas.dataset.labels || '[]');
    var values = JSON.parse(canvas.dataset.values || '[]');
    var context = canvas.getContext('2d');
    var gradient = context.createLinearGradient(0, 0, 0, 260);

    gradient.addColorStop(0, 'rgba(28, 126, 214, 0.2)');
    gradient.addColorStop(1, 'rgba(28, 126, 214, 0)');

    new Chart(context, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          data: values,
          backgroundColor: gradient,
          borderColor: '#1c7ed6',
          borderWidth: 2,
          fill: true,
          pointBackgroundColor: '#ffffff',
          pointBorderColor: '#1c7ed6',
          pointBorderWidth: 2,
          pointHoverRadius: 4,
          pointRadius: 0,
          tension: 0.32
        }]
      },
      options: {
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            displayColors: false,
            callbacks: {
              label: function(item) {
                return item.parsed.y + (item.parsed.y === 1 ? ' notice' : ' notices');
              }
            }
          }
        },
        interaction: {
          intersect: false,
          mode: 'index'
        },
        scales: {
          x: {
            border: { display: false },
            grid: { display: false },
            ticks: {
              autoSkip: true,
              color: '#7a8b9d',
              font: { size: 10 },
              maxTicksLimit: 7,
              maxRotation: 0
            }
          },
          y: {
            beginAtZero: true,
            border: { display: false },
            grid: { color: '#edf1f5' },
            ticks: {
              color: '#7a8b9d',
              font: { size: 10 },
              precision: 0
            }
          }
        }
      }
    });
  }

  function initializeEnterpriseConsole() {
    initializeEnterpriseNavigation();
    initializeEnterpriseChart();
  }

  document.addEventListener('DOMContentLoaded', initializeEnterpriseConsole);
  document.addEventListener('turbo:load', initializeEnterpriseConsole);
})();
