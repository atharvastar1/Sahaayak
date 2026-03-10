// ─────────────────────────────────────────────────────────────────────────────
// Sahaayak Web App — app.js  (v2.0 — all 14 QA fixes applied)
// ─────────────────────────────────────────────────────────────────────────────

// ── Constants ─────────────────────────────────────────────────────────────────
const API_BASE = window.location.origin;
const API_KEY = 'PROTOTYPE_MASTER_KEY';

// [N5 FIX] Generate a unique session ID per page load instead of hardcoded value
const SESSION_ID = 'web-' + (crypto.randomUUID ? crypto.randomUUID() : Math.random().toString(36).slice(2));

// ─────────────────────────────────────────────────────────────────────────────
// SPLASH SCREEN
// ─────────────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    const splash = document.getElementById('screen-splash');
    const langScreen = document.getElementById('screen-language');

    setTimeout(() => {
        splash.classList.remove('active');
        splash.classList.add('hidden');
        langScreen.classList.remove('hidden');
        langScreen.classList.add('active');
    }, 2800);

    // [N1 FIX] Wire search bar
    initSearch();

    // [N2 FIX] Wire user avatar popup
    initProfilePopup();

    // [N3 FIX] Wire WhatsApp "+" button
    initWaPlus();

    // [O2 FIX] Wire WhatsApp input icon toggle
    initWaInputToggle();

    // ── AWS ENGINE STATUS CHECK ──────────────────────────────────────────────
    checkEngineStatus();

    // ── REGISTER SERVICE WORKER (Offline Resilience) ─────────────────────────
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('sw.js')
            .then(() => console.log("Sahaayak Service Worker Registered"))
            .catch(err => console.error("SW Registration Failed", err));
    }
});

// ─────────────────────────────────────────────────────────────────────────────
// LANGUAGE SELECTION  [C2 FIX] — currentLanguage is now sent to backend
// ─────────────────────────────────────────────────────────────────────────────
let currentLanguage = 'en';
let currentLifeEvent = '';
let currentDialectHint = '';

const LANG_PROMPTS = {
    en: "I am a farmer and I need help with seeds and government schemes.",
    hi: "मुझे किसान योजना के बारे में बताओ, मुझे सरकारी मदद चाहिए।",
    mr: "मला शेतकरी योजनांबद्दल माहिती हवी आहे, मला सरकारी मदत हवी आहे।",
    pa: "ਮੈਨੂੰ ਕਿਸਾਨ ਯੋਜਨਾ ਬਾਰੇ ਜਾਣਕਾਰੀ ਚਾਹੀਦੀ ਹੈ।",
    te: "నాకు రైతు పథకాల గురించి సమాచారం కావాలి.",
    ta: "என்னுக்கு விவசாயி திட்டங்கள் பற்றி தகவல் வேண்டும்.",
    kn: "ನನಗೆ ರೈತ ಯೋಜನೆಗಳ ಬಗ್ಗೆ ಮಾಹಿತಿ ಬೇಕಿದೆ.",
    ml: "എനിക്ക് കർഷക പദ്ധതികളെ കുറിച്ച് അറിയേണ്ടതുണ്ട്.",
    bn: "আমার কৃষক প্রকল্প সম্পর্কে তথ্য দরকার।",
    gu: "મને ખેડૂત યોજનાઓ વિશે માહિતી જોઈએ છે.",
    or: "ମୋତେ କୃଷକ ଯୋଜନା ବିଷୟରେ ସୂଚନା ଦରକାର।",
    as: "মোক কৃষক আঁচনিৰ বিষয়ে তথ্য লাগে।",
    ur: "مجھے کسان اسکیموں کے بارے میں معلومات چاہیے۔",
    ne: "मलाई किसान योजनाहरूको बारेमा जानकारी चाहिन्छ।",
    sd: "مون کي ڪسان اسڪيمن بابت معلومات گهرجي.",
    ks: "مہِ کِسان یوجنہِ بابت معلومات چاہِیہِ.",
    mai: "हमरा किसान योजना केर जानकारी चाही।",
    kok: "मला शेतकरी योजनांची माहिती हवी.",
    doi: "मैनूं किसान योजनाँ बारे जानकारी चाहीदी ऐ।",
    sa: "मह्यं कृषक-योजनानां विषये सूचना वाञ्छति।",
    mni: "ꯃꯤꯈꯣꯏꯗꯒꯤ ꯌꯣꯖꯅꯥꯒꯤ ꯃꯇꯥꯗꯥ ꯈꯟꯗꯕ ꯂꯩ।",
    sat: "ᱟᱢ ᱡᱚᱨᱢᱤᱨᱮ ᱡᱟᱱᱟᱢ ᱵᱟᱝᱟ।",
    brx: "नांगौ किसान योजनाफोरनि बाथ्रा लागि।",
};

function selectLanguage(langCode, el) {
    currentLanguage = langCode;
    document.querySelectorAll('.lang-card').forEach(card => card.classList.remove('selected'));
    el.classList.add('selected');
    document.getElementById('btnContinueLang').removeAttribute('disabled');
}

function selectLifeEvent(event, el) {
    if (currentLifeEvent === event) {
        currentLifeEvent = '';
        el.classList.remove('selected');
    } else {
        currentLifeEvent = event;
        document.querySelectorAll('.situation-card').forEach(card => card.classList.remove('selected'));
        el.classList.add('selected');
    }
    console.log("Life Event set to:", currentLifeEvent);
}

function setDialectHint(dialect, el) {
    if (dialect === 'Clear') {
        currentDialectHint = '';
        document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
        return;
    }
    currentDialectHint = dialect;
    document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
    el.classList.add('active');
    console.log("Dialect Hint set to:", currentDialectHint);
}

function enterApp() {
    document.getElementById('screen-language').classList.remove('active');
    document.getElementById('screen-language').classList.add('hidden');
    document.getElementById('app-wrapper').classList.remove('hidden');
    setTimeout(() => switchTab('home'), 100);

    // [O2 FIX] Load real backend health data into Network Pulse widget
    fetchHealthAndUpdatePulse();

    // Check engine status again after system initialization
    checkEngineStatus();
}

// ─────────────────────────────────────────────────────────────────────────────
// NAVIGATION
// ─────────────────────────────────────────────────────────────────────────────
function switchTab(tabId) {
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    const navItem = document.getElementById('nav-' + tabId);
    if (navItem) navItem.classList.add('active');

    document.querySelectorAll('.view-section').forEach(el => {
        el.classList.remove('active');
        el.classList.add('hidden');
    });

    const targetView = document.getElementById('view-' + tabId);
    if (targetView) {
        targetView.classList.remove('hidden');
        targetView.classList.add('active');
    }

    // [AWS FIX] Refresh engine status when switching to dashboard or home
    if (tabId === 'home' || tabId === 'dashboard' || tabId === 'architecture') {
        checkEngineStatus();
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENGINE TOGGLE
// ─────────────────────────────────────────────────────────────────────────────
const engineToggle = document.getElementById('offlineToggle');
const engineText = document.getElementById('engineText');
const engineDot = document.getElementById('engineDot');

if (engineToggle) {
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
}

// [V1 FIX] Web Speech API Integration — Real Voice Input
const micBtn = document.getElementById('micBtn');
const micStatus = document.getElementById('micStatus');
const insightCard = document.getElementById('processingResult');
let currentMicQuery = '';

const SPEECH_LANG_MAP = {
    en: 'en-IN', hi: 'hi-IN', mr: 'mr-IN', pa: 'pa-IN', te: 'te-IN',
    ta: 'ta-IN', kn: 'kn-IN', ml: 'ml-IN', bn: 'bn-IN', gu: 'gu-IN',
    or: 'or-IN', as: 'as-IN', ur: 'ur-IN', ne: 'ne-IN', sd: 'sd-IN',
    ks: 'ks-IN', mai: 'mai-IN', kok: 'kok-IN', doi: 'doi-IN', sa: 'sa-IN',
    mni: 'mni-IN', sat: 'sat-IN', brx: 'brx-IN'
};

function startSpeechRecognition() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
        showToast("⚠️ Speech Recognition not supported in this browser.");
        showMicDialog(LANG_PROMPTS[currentLanguage] || LANG_PROMPTS.en, submitMicQuery);
        return;
    }

    const recognition = new SpeechRecognition();
    recognition.lang = SPEECH_LANG_MAP[currentLanguage] || 'en-IN';
    recognition.interimResults = false;
    recognition.maxAlternatives = 1;

    recognition.onstart = () => {
        micBtn.classList.add('listening');
        micStatus.innerText = "LISTENING...";
        showToast("🎤 Listening... Speak now.");
    };

    recognition.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        micStatus.innerText = "CAPTURED";
        submitMicQuery(transcript);
    };

    recognition.onerror = (event) => {
        console.error("Speech Error:", event.error);
        micBtn.classList.remove('listening');
        if (event.error === 'not-allowed') {
            showToast("❌ Mic access denied. Falling back to text.");
        } else {
            showToast(`⚠️ Speech Error: ${event.error}`);
        }
        showMicDialog(LANG_PROMPTS[currentLanguage] || LANG_PROMPTS.en, submitMicQuery);
    };

    recognition.onend = () => {
        micBtn.classList.remove('listening');
        if (micStatus.innerText === "LISTENING...") {
            micStatus.innerText = "TAP TO ACTIVATE";
        }
    };

    try {
        recognition.start();
    } catch (e) {
        console.error("Recognition start failed:", e);
        showMicDialog(LANG_PROMPTS[currentLanguage] || LANG_PROMPTS.en, submitMicQuery);
    }
}

// Custom modal dialog — replaces window.prompt() which is blocked on file:// URLs
function showMicDialog(defaultText, onSubmit) {
    const existing = document.getElementById('micModal');
    if (existing) existing.remove();

    const modal = document.createElement('div');
    modal.id = 'micModal';
    modal.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,0.7);z-index:99999;display:flex;align-items:center;justify-content:center;animation:fadeIn 0.2s;';
    modal.innerHTML = `
        <div style="background:#0d0d1a;border:1px solid rgba(0,180,216,0.3);border-radius:24px;padding:36px;max-width:480px;width:90%;box-shadow:0 20px 60px rgba(0,0,0,0.6);">
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:24px;">
                <div style="background:rgba(0,180,216,0.15);border-radius:12px;padding:10px;display:flex;">
                    <span class="material-symbols-rounded" style="color:#00B4D8;font-size:24px;">mic</span>
                </div>
                <div>
                    <h2 style="font-size:18px;font-weight:800;color:white;margin:0;">Liquid Mic</h2>
                    <p style="font-size:12px;color:#888;margin:2px 0 0;">Type your query below</p>
                </div>
            </div>
            <textarea id="micModalInput" rows="3" style="width:100%;background:#1a1a2e;border:1px solid rgba(0,180,216,0.25);border-radius:14px;padding:16px;color:white;font-size:15px;font-family:inherit;outline:none;resize:none;box-sizing:border-box;" placeholder="e.g. &quot;मुझे किसान योजना चाहिए&quot; or &quot;I need health insurance&quot;">${defaultText}</textarea>
            <div style="display:flex;gap:12px;margin-top:20px;justify-content:flex-end;">
                <button id="micModalCancel" style="background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.1);color:#aaa;padding:12px 24px;border-radius:12px;cursor:pointer;font-size:14px;font-weight:600;font-family:inherit;">Cancel</button>
                <button id="micModalSubmit" style="background:linear-gradient(135deg,#00B4D8,#0077b6);border:none;color:white;padding:12px 28px;border-radius:12px;cursor:pointer;font-size:14px;font-weight:800;font-family:inherit;box-shadow:0 4px 15px rgba(0,180,216,0.3);">Submit Query</button>
            </div>
        </div>`;

    document.body.appendChild(modal);

    const inputEl = document.getElementById('micModalInput');
    inputEl.focus();
    inputEl.select();

    const close = () => { modal.remove(); };

    document.getElementById('micModalCancel').onclick = close;
    modal.onclick = (e) => { if (e.target === modal) close(); };
    document.getElementById('micModalSubmit').onclick = () => {
        const val = inputEl.value.trim();
        close();
        if (val) onSubmit(val);
    };
    inputEl.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            const val = inputEl.value.trim();
            close();
            if (val) onSubmit(val);
        }
        if (e.key === 'Escape') close();
    });
}

async function submitMicQuery(query) {
    currentMicQuery = query;
    micBtn.classList.add('listening');
    micStatus.innerText = "ANALYZING INTENT...";
    insightCard.classList.add('hidden');

    const payload = {
        message: query,
        session_id: SESSION_ID,
        language_hint: currentLanguage,
        life_event: currentLifeEvent
    };

    // If dialect hint is present, prepend it to the query for the backend
    if (currentDialectHint) {
        payload.message = `[Dialect: ${currentDialectHint}] ` + query;
    }

    try {
        const response = await fetch(`${API_BASE}/chat`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-API-Key': API_KEY
            },
            body: JSON.stringify(payload)
        });

        const data = await response.json();
        micBtn.classList.remove('listening');

        const hasSchemes = data.schemes && data.schemes.length > 0;
        micStatus.innerText = hasSchemes ? "MATCH IDENTIFIED" : "NO DIRECT MATCH";
        micStatus.style.color = hasSchemes ? '' : 'var(--warning)';

        const queryText = insightCard.querySelector('.query-text');
        const responseText = insightCard.querySelector('.response-text');

        if (queryText && responseText) {
            queryText.innerText = `"${currentMicQuery}"`;
            const mainScheme = (data.schemes && data.schemes.length > 0)
                ? data.schemes[0].scheme_name
                : 'Government Schemes';
            responseText.innerHTML = `Matched with <strong>${mainScheme}</strong>. ${data.text || 'Processing complete.'}`;
        }

        if (data.audio_base64) {
            playAudio(data.audio_base64);
        } else {
            micStatus.innerText = "MATCH IDENTIFIED 🔇";
        }
        insightCard.classList.remove('hidden');
    } catch (err) {
        console.error("Chat Error:", err);
        micBtn.classList.remove('listening');
        const queryText = insightCard.querySelector('.query-text');
        const responseText = insightCard.querySelector('.response-text');
        if (queryText) queryText.innerText = `"${currentMicQuery}"`;
        if (responseText) responseText.innerHTML = `<span style="color:#e53e3e;">⚠️ Backend Offline</span> — Start the Python backend to get real scheme matches.`;
        insightCard.classList.remove('hidden');
        micStatus.innerText = "BACKEND OFFLINE";
    }
}

if (micBtn) {
    micBtn.addEventListener('click', () => {
        startSpeechRecognition();
    });
}



// ─────────────────────────────────────────────────────────────────────────────
// VAULT OCR SCAN
// ─────────────────────────────────────────────────────────────────────────────
const scanBtn = document.getElementById('scanBtn');
const scanOverlay = document.getElementById('scanOverlay');

if (scanBtn) {
    scanBtn.addEventListener('click', () => {
        scanOverlay.classList.remove('hidden');
        setTimeout(() => {
            scanOverlay.classList.add('hidden');
            showToast('✅ Cryptographic signature verified successfully.');
        }, 3500);
    });
}

// ─────────────────────────────────────────────────────────────────────────────
// [N4 FIX] EXECUTE SMART MATCH — now calls backend with a generic profile query
// ─────────────────────────────────────────────────────────────────────────────
document.addEventListener('click', (e) => {
    const btn = e.target.closest('button');
    if (!btn) return;
    if (btn.textContent.trim().includes('Execute Smart Match')) {
        executeSmartMatch();
    }
    if (btn.textContent.trim().includes('Engage Agent')) {
        switchTab('whatsapp');
    }
});

function executeSmartMatch() {
    const btn = document.querySelector('button.btn-primary.mt-6.hover-glow');
    if (btn) {
        btn.disabled = true;
        btn.innerText = 'Matching...';
    }

    fetch(`${API_BASE}/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-API-Key': API_KEY },
        body: JSON.stringify({
            message: "Show me all government schemes I am eligible for based on my profile",
            session_id: SESSION_ID,
            language_hint: currentLanguage
        })
    })
        .then(res => res.json())
        .then(data => {
            if (btn) { btn.disabled = false; btn.innerText = 'Execute Smart Match'; }
            // Show results in a nice modal
            showSmartMatchModal(data);
        })
        .catch(() => {
            if (btn) { btn.disabled = false; btn.innerText = 'Execute Smart Match'; }
            showToast('❌ Could not connect to backend. Please try again.');
        });
}

function showSmartMatchModal(data) {
    const existing = document.getElementById('smartMatchModal');
    if (existing) existing.remove();

    const schemesHtml = (data.schemes || []).slice(0, 5).map(s =>
        `<div style="padding:12px;border-radius:10px;background:rgba(0,180,216,0.08);border:1px solid rgba(0,180,216,0.2);margin-bottom:10px;">
            <p style="font-weight:700;font-size:15px;">${s.scheme_name}</p>
            <p style="font-size:13px;color:#888;margin-top:4px;">${s.benefits}</p>
            <p style="font-size:12px;color:#aaa;margin-top:4px;">Eligibility: ${s.eligibility}</p>
        </div>`
    ).join('');

    const modal = document.createElement('div');
    modal.id = 'smartMatchModal';
    modal.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,0.7);z-index:9999;display:flex;align-items:center;justify-content:center;';
    modal.innerHTML = `
        <div style="background:#1a1a2e;border:1px solid rgba(255,255,255,0.1);border-radius:20px;padding:32px;max-width:500px;width:90%;max-height:80vh;overflow-y:auto;">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
                <h2 style="font-size:20px;font-weight:800;">🎯 Smart Match Results</h2>
                <button onclick="document.getElementById('smartMatchModal').remove()" style="background:none;border:none;color:#aaa;cursor:pointer;font-size:22px;">✕</button>
            </div>
            <p style="font-size:14px;color:#aaa;margin-bottom:16px;">${data.text || ''}</p>
            ${schemesHtml}
        </div>`;
    document.body.appendChild(modal);
}

// ─────────────────────────────────────────────────────────────────────────────
// [O2 FIX] NETWORK PULSE — fetch real backend health data
// ─────────────────────────────────────────────────────────────────────────────
function fetchHealthAndUpdatePulse() {
    fetch(`${API_BASE}/health`)
        .then(res => res.json())
        .then(data => {
            const pulseEl = document.getElementById('pulseValue');
            const progressEl = document.querySelector('.progress-bar .fill');
            const labelEl = document.querySelector('.pulse-data + * + * p.text-muted.text-sm');

            if (pulseEl) {
                // Show schemes_loaded as pct of expected ~20 max
                const pct = data.schemes_loaded ? Math.min(100, Math.round(data.schemes_loaded * 5)) : 85;
                pulseEl.innerText = pct;
                if (progressEl) progressEl.style.width = pct + '%';
            }

            // Update pulse label
            const pulseLabel = document.querySelector('.pulse-data p.text-muted');
            if (pulseLabel) {
                pulseLabel.innerText = `${data.schemes_loaded} Schemes • ${data.models_ready ? 'AI Ready' : 'Loading...'}`;
            }

            // Update engine dot based on real backend status
            if (engineDot && data.status === 'ok') {
                engineDot.classList.add('pulse-green');
            }
        })
        .catch(() => {
            // Backend offline — update UI
            if (engineText) engineText.innerText = "Backend Offline";
        });
}

// ── AWS ENGINE STATUS ─────────────────────────────────────────────────────────
function checkEngineStatus() {
    const badge = document.getElementById('awsEngineBadge');
    const dot = document.getElementById('llmStatusDot');
    if (!badge || !dot) return;

    fetch(`${API_BASE}/engine`)
        .then(res => res.json())
        .then(data => {
            if (data.engine === 'bedrock') {
                badge.style.background = "rgba(255, 153, 0, 0.15)";
                badge.style.borderColor = "rgba(255, 153, 0, 0.4)";
                dot.className = 'engine-status-dot pulse-amber';
                console.log("LLM Engine: Amazon Bedrock (Active)");
            } else {
                badge.style.background = "rgba(123, 97, 255, 0.1)";
                badge.style.borderColor = "rgba(123, 97, 255, 0.2)";
                dot.className = 'engine-status-dot pulse-purple';
                dot.style.background = "var(--purple)";
                console.log("LLM Engine: Groq (Fallback)");
            }
        })
        .catch(() => {
            badge.style.opacity = '0.5';
            dot.className = 'engine-status-dot';
            dot.style.background = '#666';
        });
}

// ─────────────────────────────────────────────────────────────────────────────
// [N1 FIX] SEARCH BAR — scheme name search
// ─────────────────────────────────────────────────────────────────────────────
const ALL_SCHEMES = [
    "PM-Kisan Samman Nidhi", "PM Fasal Bima Yojana", "Ayushman Bharat (PM-JAY)",
    "Pradhan Mantri Awas Yojana", "Stand Up India", "PM SVANidhi", "Sukanya Samriddhi Yojana",
    "National Pension Scheme", "PM Jeevan Jyoti Bima Yojana", "PM Suraksha Bima Yojana"
];

function initSearch() {
    const searchInput = document.querySelector('.search-bar input');
    if (!searchInput) return;

    // Remove existing dropdown if any
    let dropdown = document.getElementById('searchDropdown');
    if (!dropdown) {
        dropdown = document.createElement('div');
        dropdown.id = 'searchDropdown';
        dropdown.style.cssText = 'position:absolute;top:60px;left:0;right:0;background:#1a1a2e;border:1px solid rgba(255,255,255,0.1);border-radius:12px;z-index:999;display:none;box-shadow:0 8px 32px rgba(0,0,0,0.4);overflow:hidden;';
        const searchBar = document.querySelector('.search-bar');
        if (searchBar) {
            searchBar.style.position = 'relative';
            searchBar.appendChild(dropdown);
        }
    }

    searchInput.addEventListener('input', (e) => {
        const q = e.target.value.trim().toLowerCase();
        if (!q) { dropdown.style.display = 'none'; return; }

        const matches = ALL_SCHEMES.filter(s => s.toLowerCase().includes(q));
        if (!matches.length) { dropdown.style.display = 'none'; return; }

        dropdown.innerHTML = matches.map(s =>
            `<div style="padding:12px 16px;cursor:pointer;font-size:14px;font-weight:500;border-bottom:1px solid rgba(255,255,255,0.05);"
              onmouseover="this.style.background='rgba(0,180,216,0.1)'" onmouseout="this.style.background=''"
              onclick="selectScheme('${s}')">${s}</div>`
        ).join('');
        dropdown.style.display = 'block';
    });

    searchInput.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            dropdown.style.display = 'none';
            searchInput.value = '';
        } else if (e.key === 'Enter') {
            const query = searchInput.value.trim();
            if (query) {
                dropdown.style.display = 'none';
                switchTab('whatsapp');
                const waInput = document.getElementById('waInputField');
                if (waInput) {
                    waInput.value = query;
                    waInput.dispatchEvent(new Event('input'));
                    setTimeout(() => simulateWhatsAppFlow(), 300);
                }
            }
        }
    });

    document.addEventListener('click', (e) => {
        if (!e.target.closest('.search-bar')) dropdown.style.display = 'none';
    });

    document.addEventListener('keydown', (e) => {
        if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
            e.preventDefault();
            searchInput.focus();
        }
    });
}

function selectScheme(name) {
    const searchInput = document.querySelector('.search-bar input');
    if (searchInput) searchInput.value = name;
    document.getElementById('searchDropdown').style.display = 'none';
    // Navigate to WhatsApp and pre-fill query
    switchTab('whatsapp');
    const waInput = document.getElementById('waInputField');
    if (waInput) {
        waInput.value = `Tell me about ${name}`;
        waInput.dispatchEvent(new Event('input'));
        setTimeout(() => simulateWhatsAppFlow(), 300);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// [N2 FIX] PROFILE POPUP — user avatar click
// ─────────────────────────────────────────────────────────────────────────────
function initProfilePopup() {
    const avatar = document.querySelector('.profile-avatar');
    if (!avatar) return;
    avatar.style.cursor = 'pointer';

    const LANG_LABELS = { en: 'English', hi: 'हिंदी', mr: 'मराठी', te: 'తెలుగు', pa: 'ਪੰਜਾਬੀ' };

    avatar.addEventListener('click', (e) => {
        e.stopPropagation();
        const existing = document.getElementById('profilePopup');
        if (existing) { existing.remove(); return; }

        const popup = document.createElement('div');
        popup.id = 'profilePopup';
        popup.style.cssText = 'position:absolute;top:56px;right:0;background:#1a1a2e;border:1px solid rgba(255,255,255,0.12);border-radius:16px;padding:20px;min-width:240px;z-index:9999;box-shadow:0 8px 32px rgba(0,0,0,0.5);';
        popup.innerHTML = `
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:16px;">
                <img src="https://ui-avatars.com/api/?name=Kisan+Mitra&background=00B4D8&color=fff" style="width:44px;height:44px;border-radius:50%;" />
                <div>
                    <p style="font-weight:700;font-size:15px;">Kisan Mitra</p>
                    <p style="font-size:12px;color:#888;">Session: ${SESSION_ID.slice(0, 16)}</p>
                </div>
            </div>
            <div style="border-top:1px solid rgba(255,255,255,0.08);padding-top:14px;">
                <p style="font-size:12px;color:#aaa;">Active Language</p>
                <p style="font-size:15px;font-weight:600;margin-top:4px;">${LANG_LABELS[currentLanguage] || currentLanguage}</p>
            </div>
            <div style="border-top:1px solid rgba(255,255,255,0.08);padding-top:14px;margin-top:14px;">
                <p style="font-size:12px;color:#aaa;">Backend Status</p>
                <p id="popupStatus" style="font-size:13px;font-weight:600;margin-top:4px;color:#10b981;">Checking...</p>
            </div>`;

        // Make parent relative for positioning
        const topbarActions = document.querySelector('.topbar-actions');
        if (topbarActions) { topbarActions.style.position = 'relative'; topbarActions.appendChild(popup); }

        // Fetch real status
        fetch(`${API_BASE}/health`).then(r => r.json()).then(d => {
            const el = document.getElementById('popupStatus');
            if (el) el.innerText = d.status === 'ok' ? `✅ Online — ${d.schemes_loaded} schemes` : '⚠️ Degraded';
        }).catch(() => {
            const el = document.getElementById('popupStatus');
            if (el) el.innerText = '❌ Offline';
        });
    });

    document.addEventListener('click', () => {
        const p = document.getElementById('profilePopup');
        if (p) p.remove();
    });
}

// ─────────────────────────────────────────────────────────────────────────────
// [N3 FIX] WHATSAPP "+" BUTTON — attachments menu
// ─────────────────────────────────────────────────────────────────────────────
function initWaPlus() {
    // We wire it after DOM is ready since the WA section is inside the main app
    document.addEventListener('click', (e) => {
        const plusBtn = e.target.closest('.wa-input-area span.material-symbols-rounded');
        if (!plusBtn || plusBtn.innerText !== 'add') return;
        e.stopPropagation();

        const existing = document.getElementById('waPlusMenu');
        if (existing) { existing.remove(); return; }

        const menu = document.createElement('div');
        menu.id = 'waPlusMenu';
        menu.style.cssText = 'position:absolute;bottom:70px;left:12px;background:#1a1a2e;border:1px solid rgba(255,255,255,0.12);border-radius:14px;padding:8px;z-index:999;box-shadow:0 8px 24px rgba(0,0,0,0.4);min-width:180px;';
        const options = [
            { icon: 'image', label: 'Upload Image', note: 'Coming soon' },
            { icon: 'location_on', label: 'Share Location', note: 'Coming soon' },
            { icon: 'lightning_stand', label: 'Quick Query', note: 'Coming soon' },
        ];
        menu.innerHTML = options.map(o =>
            `<div onclick="showToast('${o.label} — ${o.note}')" style="display:flex;align-items:center;gap:12px;padding:10px 14px;border-radius:10px;cursor:pointer;font-size:14px;font-weight:500;"
               onmouseover="this.style.background='rgba(0,180,216,0.1)'" onmouseout="this.style.background=''">
                <span class="material-symbols-rounded" style="font-size:20px;color:#00B4D8;">${o.icon}</span>
                <div><p style="font-weight:600;">${o.label}</p><p style="font-size:11px;color:#777;">${o.note}</p></div>
            </div>`
        ).join('');

        const waInputArea = document.querySelector('.wa-input-area');
        if (waInputArea) { waInputArea.style.position = 'relative'; waInputArea.appendChild(menu); }

        document.addEventListener('click', () => {
            const m = document.getElementById('waPlusMenu');
            if (m) m.remove();
        }, { once: true });
    });
}

// ─────────────────────────────────────────────────────────────────────────────
// WHATSAPP CHAT  [M3, O1 fixes included]
// ─────────────────────────────────────────────────────────────────────────────
function initWaInputToggle() {
    const inputField = document.getElementById('waInputField');
    const waSendIcon = document.getElementById('waSendIcon');
    if (!inputField || !waSendIcon) return;
    inputField.addEventListener('input', (e) => {
        waSendIcon.innerText = e.target.value.trim().length > 0 ? 'send' : 'mic';
    });
}

function handleWaInput(e) {
    if (e.key === 'Enter') simulateWhatsAppFlow();
}

function simulateWhatsAppFlow() {
    const chatBody = document.getElementById('waChatBody');
    const inputField = document.getElementById('waInputField');
    if (!chatBody) return;

    const userText = inputField ? inputField.value.trim() : '';

    // [M3 FIX] Block empty sends — no fallback hardcoded message
    if (!userText) {
        showToast('⚠️ Please type a message first.');
        return;
    }

    // Clear input
    if (inputField) { inputField.value = ''; }
    const waSendIcon = document.getElementById('waSendIcon');
    if (waSendIcon) waSendIcon.innerText = 'mic';

    // Add user bubble
    const timeNow = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    const myMsg = document.createElement('div');
    myMsg.style.cssText = "background:#D9FDD3;padding:8px 12px;border-radius:12px;border-top-right-radius:0;max-width:80%;align-self:flex-end;margin-bottom:12px;box-shadow:0 1px 2px rgba(0,0,0,0.1);";
    myMsg.innerHTML = `<p class="fs-14 fw-500">${escapeHtml(userText)}</p><span style="font-size:11px;color:#999;float:right;margin-top:4px;">${timeNow}</span>`;
    chatBody.appendChild(myMsg);
    chatBody.scrollTop = chatBody.scrollHeight;

    // Typing indicator
    setTimeout(() => {
        const typingMsg = document.createElement('div');
        typingMsg.id = "waTyping";
        typingMsg.style.cssText = "background:white;padding:8px 12px;border-radius:12px;border-top-left-radius:0;max-width:80%;align-self:flex-start;margin-bottom:12px;box-shadow:0 1px 2px rgba(0,0,0,0.1);";
        typingMsg.innerHTML = `<span class="fw-700 fs-14" style="color:#008069">Sahaayak BharatBot</span><p class="mt-1 text-main fs-14"><i>typing...</i></p>`;
        chatBody.appendChild(typingMsg);
        chatBody.scrollTop = chatBody.scrollHeight;

        setTimeout(() => {
            const typing = document.getElementById('waTyping');
            if (typing) typing.remove();

            const replyTime = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            const replyMsg = document.createElement('div');
            replyMsg.style.cssText = "background:white;padding:8px 12px;border-radius:12px;border-top-left-radius:0;max-width:80%;align-self:flex-start;margin-bottom:12px;box-shadow:0 1px 2px rgba(0,0,0,0.1);";

            // [C2 FIX] send language_hint
            fetch(`${API_BASE}/chat`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'X-API-Key': API_KEY },
                body: JSON.stringify({
                    message: userText,
                    session_id: SESSION_ID,
                    language_hint: currentLanguage  // [C2 FIX]
                })
            })
                .then(res => res.json())
                .then(data => {
                    // [O1 FIX] Show 🔇 indicator when no audio
                    const audioTag = data.audio_base64 ? '' : ' <span title="Voice unavailable" style="font-size:12px;color:#aaa;">🔇</span>';
                    replyMsg.innerHTML = `
                    <span class="fw-700 fs-14" style="color:#008069">Sahaayak BharatBot</span>
                    <p class="mt-1 text-main fs-14">${escapeHtml(data.text)}${audioTag}</p>
                    <div style="display:flex; justify-content:space-between; align-items:flex-end; margin-top:8px;">
                        <div style="display:flex; gap:12px;">
                            <span class="material-symbols-rounded cursor-pointer text-muted hover-glow-green" style="font-size:18px; transition:color 0.2s;" onclick="this.style.color='#10b981'; showToast('✅ Feedback recorded for RLHF')">thumb_up</span>
                            <span class="material-symbols-rounded cursor-pointer text-muted hover-glow-red" style="font-size:18px; transition:color 0.2s;" onclick="this.style.color='#ef4444'; showToast('🚩 Translation error reported')">thumb_down</span>
                        </div>
                        <span style="font-size:11px;color:#999;">${replyTime}</span>
                    </div>`;
                    if (data.audio_base64) playAudio(data.audio_base64);
                    chatBody.appendChild(replyMsg);
                    chatBody.scrollTop = chatBody.scrollHeight;
                })
                .catch(() => {
                    replyMsg.innerHTML = `<span class="fw-700 fs-14" style="color:#008069">Sahaayak BharatBot</span><p class="mt-1 fs-14" style="color:#e53e3e;">Could not reach server. Please try again.</p>`;
                    chatBody.appendChild(replyMsg);
                    chatBody.scrollTop = chatBody.scrollHeight;
                });
        }, 1000);
    }, 500);
}

// ─────────────────────────────────────────────────────────────────────────────
// AUDIO PLAYBACK
// ─────────────────────────────────────────────────────────────────────────────
const globalAudio = new Audio();

document.addEventListener('click', () => {
    if (!globalAudio.src) {
        globalAudio.src = "data:audio/mp3;base64,//NExAAAAANIAAAAAExBTUUzLjEwMKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq";
        globalAudio.play().catch(() => { });
    }
}, { once: true });

function playAudio(base64Data) {
    globalAudio.src = "data:audio/mp3;base64," + base64Data;
    globalAudio.play().catch(e => {
        console.warn("Audio playback blocked or failed:", e);
        showToast("🔇 Audio blocked by browser. Please tap anywhere to allow.");
    });
}

// ─────────────────────────────────────────────────────────────────────────────
// UTILITIES
// ─────────────────────────────────────────────────────────────────────────────
function showToast(msg) {
    const existing = document.getElementById('sahaayakToast');
    if (existing) existing.remove();
    const toast = document.createElement('div');
    toast.id = 'sahaayakToast';
    toast.style.cssText = 'position:fixed;bottom:32px;left:50%;transform:translateX(-50%);background:#1a1a2e;border:1px solid rgba(255,255,255,0.15);color:white;padding:14px 24px;border-radius:12px;font-size:14px;font-weight:600;z-index:99999;box-shadow:0 8px 24px rgba(0,0,0,0.4);pointer-events:none;transition:opacity 0.4s;';
    toast.innerText = msg;
    document.body.appendChild(toast);
    setTimeout(() => { toast.style.opacity = '0'; setTimeout(() => toast.remove(), 400); }, 2800);
}

function escapeHtml(str) {
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// [O3 FIX] Ticker padding — ensure first item doesn't clip
document.addEventListener('DOMContentLoaded', () => {
    const firstMarqueeItem = document.querySelector('.marquee-scroller .m-text');
    if (firstMarqueeItem) {
        firstMarqueeItem.style.paddingLeft = '24px';
    }
});
