// Splash Screen Logic
document.addEventListener('DOMContentLoaded', () => {
    const splash = document.getElementById('screen-splash');
    const langScreen = document.getElementById('screen-language');

    setTimeout(() => {
        splash.classList.remove('active');
        splash.classList.add('hidden');

        langScreen.classList.remove('hidden');
        langScreen.classList.add('active');
    }, 2800);
});

// Language Select Logic
let currentLanguage = 'en';

function selectLanguage(langCode, el) {
    currentLanguage = langCode;
    document.querySelectorAll('.lang-card').forEach(card => card.classList.remove('selected'));
    el.classList.add('selected');
    document.getElementById('btnContinueLang').removeAttribute('disabled');
}

function enterApp() {
    document.getElementById('screen-language').classList.remove('active');
    document.getElementById('screen-language').classList.add('hidden');

    // Simulate slight loading to main app
    document.getElementById('app-wrapper').classList.remove('hidden');
    // Start pulse animation on dashboard entrance
    setTimeout(() => switchTab('home'), 100);
}

// Navigation Logic
function switchTab(tabId) {
    // Nav Items
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    document.getElementById('nav-' + tabId).classList.add('active');

    // Views
    document.querySelectorAll('.view-section').forEach(el => {
        el.classList.remove('active');
        el.classList.add('hidden');
    });

    const targetView = document.getElementById('view-' + tabId);
    targetView.classList.remove('hidden');
    targetView.classList.add('active');
}

// Engine Toggle Logic
const engineToggle = document.getElementById('offlineToggle');
const engineText = document.getElementById('engineText');
const engineDot = document.getElementById('engineDot');

engineToggle.addEventListener('change', (e) => {
    if (e.target.checked) {
        engineText.innerText = "Secure Local Connection";
        engineText.style.color = "var(--green)";
        engineDot.style.background = "var(--green)";
        engineDot.style.boxShadow = "0 0 10px rgba(16, 185, 129, 0.4)";
        engineDot.classList.add('pulse-green');
        engineDot.parentElement.style.borderColor = "rgba(16, 185, 129, 0.2)";
        engineDot.parentElement.style.background = "rgba(16, 185, 129, 0.05)";
    } else {
        engineText.innerText = "Cloud Sync Active";
        engineText.style.color = "var(--cyan)";
        engineDot.style.background = "var(--cyan)";
        engineDot.style.boxShadow = "0 0 10px rgba(0, 180, 216, 0.4)";
        engineDot.classList.remove('pulse-green');
        engineDot.parentElement.style.borderColor = "rgba(0, 180, 216, 0.2)";
        engineDot.parentElement.style.background = "rgba(0, 180, 216, 0.05)";
    }
});

// Mic Simulation
const micBtn = document.getElementById('micBtn');
const micStatus = document.getElementById('micStatus');
const insightCard = document.getElementById('processingResult');

if (micBtn) {
    micBtn.addEventListener('click', () => {
        micBtn.classList.add('listening');
        micStatus.innerText = "LISTENING... (Speak Naturally)";
        insightCard.classList.add('hidden');

        setTimeout(() => {
            micBtn.classList.remove('listening');
            micStatus.innerText = "ANALYZING INTENT...";

            setTimeout(() => {
                micStatus.innerText = "MATCH IDENTIFIED";
                insightCard.classList.remove('hidden');
            }, 1200);
        }, 3000);
    });
}

// Vault Scan Simulation
const scanBtn = document.getElementById('scanBtn');
const scanOverlay = document.getElementById('scanOverlay');

if (scanBtn) {
    scanBtn.addEventListener('click', () => {
        scanOverlay.classList.remove('hidden');

        setTimeout(() => {
            scanOverlay.classList.add('hidden');
            // Adding a small visual notification that scan was successful.
            alert("Cryptographic signature verified successfully.");
        }, 3500);
    });
}

// Pulse value animation
setInterval(() => {
    const pulseEl = document.getElementById('pulseValue');
    if (pulseEl && document.getElementById('view-dashboard').classList.contains('active')) {
        // Simulate a live pulse fluctuation
        let val = Math.floor(Math.random() * (92 - 82 + 1)) + 82;
        pulseEl.innerText = val;
    }
}, 4000);
