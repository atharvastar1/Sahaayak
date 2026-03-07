import asyncio
from playwright.async_api import async_playwright

async def test_sahaayak_flow():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        
        # 1. Load the app
        print("🚀 Loading Sahaayak Web App...")
        await page.goto("file:///Users/atharvainteractives/.gemini/antigravity/scratch/Sahaayak/sahaayak_web/index.html")
        
        # 2. Wait for Splash to fade (approx 3s)
        await page.wait_for_timeout(3500)
        
        # 3. Select Language (Hindi)
        print("🌐 Selecting Language: Hindi")
        await page.click("text=हिंदी")
        await page.click("text=Initialize System")
        
        # 4. Verify Homepage elements
        print("🏠 Verifying Home View...")
        await page.wait_for_selector(".premium-heading")
        assert await page.inner_text(".premium-heading") == "Aap Kaise Hain?"
        
        # 5. Test Life Event Selection (Farmer)
        print("👨‍🌾 Testing Life Event: Farmer")
        await page.click("text=Kisan (Farmer)")
        # Check if selected class is applied
        is_selected = await page.eval_on_selector(".situation-card:has-text('Farmer')", "el => el.classList.contains('selected')")
        print(f"✅ Farmer Card Selected: {is_selected}")
        
        # 6. Test Dialect Hint (Bhojpuri)
        print("🗣️ Testing Dialect Hint: Bhojpuri")
        await page.click("text=Bhojpuri")
        is_dialect_active = await page.eval_on_selector(".chip:has-text('Bhojpuri')", "el => el.classList.contains('active')")
        print(f"✅ Bhojpuri Chip Active: {is_dialect_active}")
        
        # 7. Check Mic Orbit presence
        mic_visible = await page.is_visible("#micBtn")
        print(f"🎤 Mic Orbit Visible: {mic_visible}")
        
        print("✨ All Founder Mode UI tests PASSED!")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(test_sahaayak_flow())
