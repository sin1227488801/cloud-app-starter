/**
 * SRE IaC Starter - Landing Page Script
 * Handles meta.json loading, status updates, and UI interactions
 */

(function() {
    'use strict';

    // DOM Elements
    const elements = {
        websiteUrl: document.getElementById('website-url'),
        storageAccount: document.getElementById('storage-account'),
        deployTime: document.getElementById('deploy-time'),
        gitSha: document.getElementById('git-sha'),
        originLink: document.getElementById('origin-link'),
        ciBadge: document.getElementById('ci-badge'),
        deployBadge: document.getElementById('deploy-badge'),
        statusBadge: document.getElementById('status-badge')
    };

    // Initialize the application
    function init() {
        setupOriginLink();
        loadMetadata();
        setupAnimations();
        
        // Refresh metadata every 30 seconds
        setInterval(loadMetadata, 30000);
    }

    /**
     * Setup origin link
     */
    function setupOriginLink() {
        if (elements.originLink) {
            elements.originLink.href = window.location.origin;
        }
    }

    /**
     * Load deployment metadata
     */
    async function loadMetadata() {
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
            updateStatus(meta);
            updateBadges(true);

        } catch (error) {
            console.warn('Failed to load meta.json:', error.message);
            showFallbackData();
            updateBadges(false);
        }
    }

    /**
     * Update status display with metadata
     */
    function updateStatus(meta) {
        // Website URL
        if (elements.websiteUrl && meta.websiteUrl) {
            elements.websiteUrl.textContent = meta.websiteUrl;
            elements.websiteUrl.href = meta.websiteUrl;
            elements.websiteUrl.title = `Open website: ${meta.websiteUrl}`;
        }

        // Storage Account
        if (elements.storageAccount && meta.storageAccountName) {
            elements.storageAccount.textContent = meta.storageAccountName;
            elements.storageAccount.title = `Azure Storage Account: ${meta.storageAccountName}`;
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
                link.style.color = 'var(--color-primary)';
                link.style.textDecoration = 'none';
                link.addEventListener('mouseenter', () => {
                    link.style.textDecoration = 'underline';
                });
                link.addEventListener('mouseleave', () => {
                    link.style.textDecoration = 'none';
                });
                
                elements.gitSha.innerHTML = '';
                elements.gitSha.appendChild(link);
            }
        }
    }

    /**
     * Show fallback data when meta.json is not available
     */
    function showFallbackData() {
        const fallbackData = {
            websiteUrl: window.location.origin,
            storageAccount: 'sreiacdevm627ymaf',
            deployTime: new Date(),
            gitSha: 'local-dev'
        };

        // Website URL
        if (elements.websiteUrl) {
            elements.websiteUrl.textContent = fallbackData.websiteUrl;
            elements.websiteUrl.href = fallbackData.websiteUrl;
        }

        // Storage Account
        if (elements.storageAccount) {
            elements.storageAccount.textContent = fallbackData.storageAccount;
        }

        // Deploy Time
        if (elements.deployTime) {
            elements.deployTime.textContent = formatDeployTime(fallbackData.deployTime);
        }

        // Git SHA
        if (elements.gitSha) {
            elements.gitSha.textContent = fallbackData.gitSha;
        }
    }

    /**
     * Update badge status
     */
    function updateBadges(isSuccess) {
        if (elements.ciBadge) {
            const ciIcon = elements.ciBadge.querySelector('.badge-icon');
            const ciText = elements.ciBadge.querySelector('span:last-child');
            
            if (isSuccess) {
                ciIcon.textContent = '✅';
                ciText.textContent = 'CI: Passed';
                elements.ciBadge.className = 'badge success';
            } else {
                ciIcon.textContent = '⚠️';
                ciText.textContent = 'CI: Warning';
                elements.ciBadge.className = 'badge warning';
            }
        }

        if (elements.deployBadge) {
            const deployIcon = elements.deployBadge.querySelector('.badge-icon');
            const deployText = elements.deployBadge.querySelector('span:last-child');
            
            if (isSuccess) {
                deployIcon.textContent = '🚀';
                deployText.textContent = 'Deploy: Live';
                elements.deployBadge.className = 'badge info';
            } else {
                deployIcon.textContent = '⏸️';
                deployText.textContent = 'Deploy: Pending';
                elements.deployBadge.className = 'badge warning';
            }
        }

        if (elements.statusBadge) {
            const statusIcon = elements.statusBadge.querySelector('.badge-icon');
            const statusText = elements.statusBadge.querySelector('span:last-child');
            
            statusIcon.textContent = '⚡';
            statusText.textContent = 'Status: Active';
            elements.statusBadge.className = 'badge success';
        }
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
     * Setup animations and interactions
     */
    function setupAnimations() {
        // Add loading animation to status values initially
        Object.values(elements).forEach(element => {
            if (element && element.textContent === 'Loading...') {
                element.classList.add('loading');
            }
        });

        // Remove loading animation after 3 seconds
        setTimeout(() => {
            Object.values(elements).forEach(element => {
                if (element) {
                    element.classList.remove('loading');
                }
            });
        }, 3000);

        // Add hover effects to architecture nodes
        const archNodes = document.querySelectorAll('.arch-node');
        archNodes.forEach(node => {
            node.addEventListener('mouseenter', () => {
                node.style.transform = 'scale(1.05)';
            });
            
            node.addEventListener('mouseleave', () => {
                node.style.transform = 'scale(1)';
            });
        });

        // Add click effects to cards
        const cards = document.querySelectorAll('.phase-card, .status-card, .workflow-card, .link-card');
        cards.forEach(card => {
            card.addEventListener('click', (e) => {
                // Only add effect if it's not a link
                if (!card.href) {
                    card.style.transform = 'scale(0.98)';
                    setTimeout(() => {
                        card.style.transform = '';
                    }, 150);
                }
            });
        });
    }

    /**
     * Handle theme changes (if needed in the future)
     */
    function handleThemeChange() {
        const mediaQuery = window.matchMedia('(prefers-color-scheme: light)');
        
        function updateTheme(e) {
            // Currently using dark theme only, but ready for light theme
            document.documentElement.setAttribute('data-theme', e.matches ? 'light' : 'dark');
        }
        
        mediaQuery.addListener(updateTheme);
        updateTheme(mediaQuery);
    }

    /**
     * Error handling for uncaught errors
     */
    window.addEventListener('error', (event) => {
        console.error('Uncaught error:', event.error);
    });

    window.addEventListener('unhandledrejection', (event) => {
        console.error('Unhandled promise rejection:', event.reason);
    });

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Initialize theme handling
    handleThemeChange();

})();