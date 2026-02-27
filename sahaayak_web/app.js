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

// WhatsApp Simulation Logic
let waFlowStep = 0;

// Update mic icon to send icon when typing
document.addEventListener('DOMContentLoaded', () => {
    const inputField = document.getElementById('waInputField');
    const waSendIcon = document.getElementById('waSendIcon');
    if (inputField && waSendIcon) {
        inputField.addEventListener('input', (e) => {
            if (e.target.value.trim().length > 0) {
                waSendIcon.innerText = 'send';
            } else {
                waSendIcon.innerText = 'mic';
            }
        });
    }
});

function handleWaInput(e) {
    if (e.key === 'Enter') {
        simulateWhatsAppFlow();
    }
}

function simulateWhatsAppFlow() {
    const chatBody = document.getElementById('waChatBody');
    const inputField = document.getElementById('waInputField');
    if (!chatBody) return;

    let userText = "I need help with seeds. I am a farmer in UP.";
    if (inputField && inputField.value.trim().length > 0) {
        userText = inputField.value.trim();
        inputField.value = '';
        const waSendIcon = document.getElementById('waSendIcon');
        if (waSendIcon) waSendIcon.innerText = 'mic';
    }

    // Add User Message
    const myMsg = document.createElement('div');
    const timeNow = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    myMsg.innerHTML = `<p class="fs-14 fw-500">${userText}</p><span style="font-size:11px; color:#999; float:right; margin-top:4px;">${timeNow}</span>`;
    myMsg.style = "background:#D9FDD3; padding:8px 12px; border-radius:12px; border-top-right-radius:0; max-width:80%; align-self:flex-end; margin-bottom:12px; box-shadow:0 1px 2px rgba(0,0,0,0.1);";
    chatBody.appendChild(myMsg);
    chatBody.scrollTop = chatBody.scrollHeight;

    // Typing indicator
    setTimeout(() => {
        const typingMsg = document.createElement('div');
        typingMsg.id = "waTyping";
        typingMsg.innerHTML = `<span class="fw-700 text-green fs-14" style="color:#008069">Sahaayak AI</span><p class="mt-1 text-main fs-14"><i>typing...</i></p>`;
        typingMsg.style = "background:white; padding:8px 12px; border-radius:12px; border-top-left-radius:0; max-width:80%; align-self:flex-start; margin-bottom:12px; box-shadow:0 1px 2px rgba(0,0,0,0.1);";
        chatBody.appendChild(typingMsg);
        chatBody.scrollTop = chatBody.scrollHeight;

        // Response logic
        setTimeout(() => {
            const typing = document.getElementById('waTyping');
            if (typing) typing.remove();

            const replyMsg = document.createElement('div');
            let replyHtml = "";
            const replyTime = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

            if (waFlowStep === 0) {
                replyHtml = `<span class="fw-700 text-green fs-14" style="color:#008069">Sahaayak AI</span><p class="mt-1 text-main fs-14">Based on your query, you are eligible for the <b>PM Kisan Samman Nidhi</b> scheme! You qualify for ₹2000 in your linked bank account. Type <b>APPLY</b> to proceed.</p><span style="font-size:11px; color:#999; float:right; margin-top:4px;">${replyTime}</span>`;
            } else if (waFlowStep === 1) {
                replyHtml = `<span class="fw-700 text-green fs-14" style="color:#008069">Sahaayak AI</span><p class="mt-1 text-main fs-14">Processing your application using your registered Aadhaar... ✅<br><br><b>Success!</b> Your application #49820 is submitted.</p><span style="font-size:11px; color:#999; float:right; margin-top:4px;">${replyTime}</span>`;
            } else {
                replyHtml = `<span class="fw-700 text-green fs-14" style="color:#008069">Sahaayak AI</span><p class="mt-1 text-main fs-14">I am still here to help! Send another voice note or text message about any other schemes.</p><span style="font-size:11px; color:#999; float:right; margin-top:4px;">${replyTime}</span>`;
                waFlowStep = -1; // Reset flow
            }

            replyMsg.innerHTML = replyHtml;
            replyMsg.style = "background:white; padding:8px 12px; border-radius:12px; border-top-left-radius:0; max-width:80%; align-self:flex-start; margin-bottom:12px; box-shadow:0 1px 2px rgba(0,0,0,0.1);";
            chatBody.appendChild(replyMsg);
            chatBody.scrollTop = chatBody.scrollHeight;

            waFlowStep++;

        }, (Math.random() * 1000) + 1000); // 1-2 second response time
    }, 500); // 0.5s delay before typing shows
}
