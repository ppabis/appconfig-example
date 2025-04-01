const REFRESH_INTERVAL = 5000; // 5 seconds
let progressBar = document.getElementById('progressBar');
let lastUpdateTime = Date.now();
let refreshTimeout = null;
let animationFrameId = null;

function updateProgressBar() {
    const elapsed = Date.now() - lastUpdateTime;
    const progress = (elapsed / REFRESH_INTERVAL) * 100;
    const clampedProgress = Math.min(100, progress);
    progressBar.style.transform = `scaleX(${1 - (clampedProgress / 100)})`;
    
    if (progress < 100) {
        animationFrameId = requestAnimationFrame(updateProgressBar);
    }
}

async function refreshValues() {
    // Clear any existing timeout
    if (refreshTimeout) {
        clearTimeout(refreshTimeout);
    }
    // Cancel any existing animation frame
    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }

    try {
        const response = await fetch('/refresh');
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        const data = await response.json();
        
        // Update all values
        document.getElementById('ssm_parameter').textContent = data.ssm_parameter;
        document.getElementById('ssm_secret_parameter').textContent = data.ssm_secret_parameter;
        document.getElementById('s3_env_parameter').textContent = data.s3_env_parameter;
        document.getElementById('secrets_manager_parameter').textContent = data.secrets_manager_parameter;
        document.getElementById('lastRefresh').firstElementChild.textContent = `Last refreshed: ${data.last_refresh}`;
    } catch (error) {
        console.error('Error refreshing values:', error);
    } finally {
        // Reset timer and progress bar
        lastUpdateTime = Date.now();
        progressBar.style.transform = 'scaleX(1)';
        animationFrameId = requestAnimationFrame(updateProgressBar);
        // Schedule next update with a clean timeout
        refreshTimeout = setTimeout(refreshValues, REFRESH_INTERVAL);
    }
}

// Start the refresh cycle when the DOM is loaded
document.addEventListener('DOMContentLoaded', refreshValues); 