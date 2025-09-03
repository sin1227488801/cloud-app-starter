/**
 * Cloud App Starter - Main JavaScript
 * Handles meta.json loading, copy functionality, and UI interactions
 */

// DOM Content Loaded
document.addEventListener('DOMContentLoaded', function () {
    loadDeploymentMeta();
    initializeUI();
});

/**
 * Load deployment metadata from meta.json
 */
async function loadDeploymentMeta() {
    try {
        const response = await fetch('./meta.json', {
            cache: 'no-store',
            headers: {
                'Cache-Control': 'no-cache'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const meta = await response.json();
        updateDeploymentStatus(meta);

    } catch (error) {
        console.warn('Failed to load meta.json:', error.message);
        showPlaceholderStatus();
    }
}

/**
 * Update deployment status in the UI
 */
function updateDeploymentStatus(meta) {
    const elements = {
        storageAccount: document.getElementById('storage-account'),
        websiteUrl: document.getElementById('website-url'),
        deployTime: document.getElementById('deploy-time'),
        gitSha: document.getElementById('git-sha')
    };

    // Storage Account
    if (elements.storageAccount && meta.storageAccountName) {
        elements.storageAccount.textContent = meta.storageAccountName;
        elements.storageAccount.title = `Azure Storage Account: ${meta.storageAccountName}`;
    }

    // Website URL
    if (elements.websiteUrl && meta.websiteUrl) {
        elements.websiteUrl.textContent = meta.websiteUrl;
        elements.websiteUrl.href = meta.websiteUrl;
        elements.websiteUrl.title = `Open website: ${meta.websiteUrl}`;
    }

    // Deploy Time
    if (elements.deployTime && meta.deployedAt) {
        const deployDate = new Date(meta.deployedAt);
        const formattedTime = formatDeployTime(deployDate);
        elements.deployTime.textContent = formattedTime;
        elements.deployTime.title = `Deployed at: ${deployDate.toISOString()}`;
    }

    // Git SHA
    if (elements.gitSha && meta.commitSha) {
        const shortSha = meta.commitSha.substring(0, 8);
        elements.gitSha.textContent = shortSha;
        elements.gitSha.title = `Full SHA: ${meta.commitSha}`;

        // Make it clickable if we have a repo URL
        if (meta.repositoryUrl) {
            const link = document.createElement('a');
            link.href = `${meta.repositoryUrl}/commit/${meta.commitSha}`;
            link.target = '_blank';
            link.rel = 'noopener';
            link.textContent = shortSha;
            link.title = `View commit: ${meta.commitSha}`;
            link.className = 'status-link';
            elements.gitSha.innerHTML = '';
            elements.gitSha.appendChild(link);
        }
    }
}

/**
 * Show placeholder status when meta.json is not available
 */
function showPlaceholderStatus() {
    const placeholders = {
        'storage-account': 'cloudappdevm627ymaf',
        'website-url': 'https://cloudappdevm627ymaf.z11.web.core.windows.net/',
        'deploy-time': formatDeployTime(new Date()),
        'git-sha': 'local-dev'
    };

    Object.entries(placeholders).forEach(([id, value]) => {
        const element = document.getElementById(id);
        if (element) {
            if (id === 'website-url') {
                element.textContent = value;
                element.href = value;
            } else {
                element.textContent = value;
            }
        }
    });
}

/**
 * Format deploy time for display
 */
function formatDeployTime(date) {
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / (1000 * 60));
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

    if (diffMins < 1) {
        return 'Just now';
    } else if (diffMins < 60) {
        return `${diffMins}分前`;
    } else if (diffHours < 24) {
        return `${diffHours}時間前`;
    } else if (diffDays < 7) {
        return `${diffDays}日前`;
    } else {
        return date.toLocaleDateString('ja-JP', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }
}

/**
 * Copy text to clipboard
 */
async function copyToClipboard(text) {
    try {
        if (navigator.clipboard && window.isSecureContext) {
            await navigator.clipboard.writeText(text);
        } else {
            // Fallback for older browsers or non-HTTPS
            const textArea = document.createElement('textarea');
            textArea.value = text;
            textArea.style.position = 'fixed';
            textArea.style.left = '-999999px';
            textArea.style.top = '-999999px';
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            document.execCommand('copy');
            textArea.remove();
        }

        showCopyFeedback();

    } catch (error) {
        console.error('Failed to copy to clipboard:', error);
        showCopyError();
    }
}

/**
 * Show copy success feedback
 */
function showCopyFeedback() {
    // Create temporary feedback element
    const feedback = document.createElement('div');
    feedback.textContent = '✅ Copied!';
    feedback.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: var(--color-success);
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        font-weight: 500;
        z-index: 1000;
        animation: slideIn 0.3s ease;
    `;

    document.body.appendChild(feedback);

    setTimeout(() => {
        feedback.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => feedback.remove(), 300);
    }, 2000);
}

/**
 * Show copy error feedback
 */
function showCopyError() {
    const feedback = document.createElement('div');
    feedback.textContent = '❌ Copy failed';
    feedback.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: var(--color-error);
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        font-weight: 500;
        z-index: 1000;
        animation: slideIn 0.3s ease;
    `;

    document.body.appendChild(feedback);

    setTimeout(() => {
        feedback.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => feedback.remove(), 300);
    }, 3000);
}

/**
 * Scroll to section
 */
function scrollToSection(sectionId) {
    const element = document.getElementById(sectionId);
    if (element) {
        element.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
    }
}

/**
 * Initialize UI interactions
 */
function initializeUI() {
    // Add CSS animations
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(style);

    // Add keyboard navigation for copy buttons
    document.querySelectorAll('.copy-btn').forEach(btn => {
        btn.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                btn.click();
            }
        });
    });

    // Architecture nodes styling handled by CSS only

    // Refresh meta.json every 30 seconds
    setInterval(loadDeploymentMeta, 30000);
}

/**
 * Handle theme changes
 */
function handleThemeChange() {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');

    function updateTheme(e) {
        document.documentElement.setAttribute('data-theme', e.matches ? 'dark' : 'light');
    }

    mediaQuery.addListener(updateTheme);
    updateTheme(mediaQuery);
}

// Initialize theme handling
handleThemeChange();

// Make functions globally available
window.copyToClipboard = copyToClipboard;
window.scrollToSection = scrollToSection;
