import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

STORE_DIR = r"D:\Antigravity\Qadir Apps\FocusTime\store_listing"
MIPMAP_DIR = r"D:\Antigravity\Qadir Apps\FocusTime\android\app\src\main\res"
ASSETS_IMG = r"D:\Antigravity\Qadir Apps\FocusTime\assets\images"
os.makedirs(STORE_DIR, exist_ok=True)
os.makedirs(ASSETS_IMG, exist_ok=True)

def create_gradient_circle(width, height):
    base = Image.new("RGBA", (width, height), (15, 23, 42, 255))
    draw = ImageDraw.Draw(base)
    # Radial glow from center
    cx, cy = width / 2, height / 2
    max_r = math.sqrt(cx**2 + cy**2)
    for r in range(int(max_r), 0, -3):
        frac = r / max_r
        # Gradient from center indigo/violet (79, 70, 229) to edge dark twilight (15, 23, 42)
        red = int(79 * (1 - frac) + 15 * frac)
        green = int(70 * (1 - frac) + 23 * frac)
        blue = int(229 * (1 - frac) + 42 * frac)
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(red, green, blue, 255))
    return base

def draw_icon_512():
    size = 512
    img = create_gradient_circle(size, size)
    
    # Create smooth overlay with subtle inner radial vignette
    overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    cx, cy = size / 2, size / 2
    
    # Outer ambient glow ring
    for r_offset in range(12, 0, -2):
        alpha = int(25 * (1 - r_offset / 12))
        draw.ellipse([cx - 170 - r_offset, cy - 170 - r_offset, cx + 170 + r_offset, cy + 170 + r_offset],
                     outline=(56, 189, 248, alpha), width=3)
    
    # Main outer track ring (dark translucent)
    draw.ellipse([cx - 165, cy - 165, cx + 165, cy + 165], outline=(255, 255, 255, 40), width=14)
    
    # Dynamic glowing progress arc (0 to 280 degrees)
    # Electric cyan into vibrant violet
    for deg in range(0, 275):
        rad = math.radians(deg - 90)
        # Gradient color along arc
        t = deg / 275.0
        r = int(56 * (1 - t) + 168 * t)
        g = int(189 * (1 - t) + 85 * t)
        b = int(248 * (1 - t) + 247 * t)
        
        rx = cx + 165 * math.cos(rad)
        ry = cy + 165 * math.sin(rad)
        draw.ellipse([rx - 8, ry - 8, rx + 8, ry + 8], fill=(r, g, b, 255))
        
    # Arc tip bright accent cap
    tip_rad = math.radians(275 - 90)
    tip_x = cx + 165 * math.cos(tip_rad)
    tip_y = cy + 165 * math.sin(tip_rad)
    draw.ellipse([tip_x - 12, tip_y - 12, tip_x + 12, tip_y + 12], fill=(255, 255, 255, 255))
    
    # Inner circular disc with frosted glass effect
    for r in range(125, 0, -2):
        alpha = int(45 + 50 * (1 - r / 125))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(30, 41, 59, alpha))
        
    draw.ellipse([cx - 125, cy - 125, cx + 125, cy + 125], outline=(255, 255, 255, 60), width=3)
    
    # Center stylized minimalist Zen Hourglass / Play Spark symbol
    # Hourglass triangles
    # Top triangle
    top_tri = [(cx - 48, cy - 65), (cx + 48, cy - 65), (cx, cy - 6)]
    draw.polygon(top_tri, fill=(245, 158, 11, 230))
    # Bottom triangle
    bot_tri = [(cx, cy + 6), (cx + 48, cy + 65), (cx - 48, cy + 65)]
    draw.polygon(bot_tri, fill=(251, 191, 36, 240))
    
    # Center luminous bead
    draw.ellipse([cx - 9, cy - 9, cx + 9, cy + 9], fill=(255, 255, 255, 255))
    
    # Dial tick notches around rim
    for a in range(0, 360, 30):
        rad = math.radians(a)
        x1 = cx + 138 * math.cos(rad)
        y1 = cy + 138 * math.sin(rad)
        x2 = cx + 148 * math.cos(rad)
        y2 = cy + 148 * math.sin(rad)
        draw.line([(x1, y1), (x2, y2)], fill=(255, 255, 255, 140), width=3)
        
    combined = Image.alpha_composite(img, overlay)
    
    # Save icon_512x512.png
    out_path = os.path.join(STORE_DIR, "icon_512x512.png")
    combined.save(out_path, format="PNG")
    print(f"Saved {out_path}")
    
    # Also save in assets/images/app_icon.png
    asset_icon_path = os.path.join(ASSETS_IMG, "app_icon.png")
    combined.save(asset_icon_path, format="PNG")
    
    # Generate mipmaps for Android launcher
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, dim in sizes.items():
        res_folder = os.path.join(MIPMAP_DIR, folder)
        os.makedirs(res_folder, exist_ok=True)
        scaled = combined.resize((dim, dim), Image.Resampling.LANCZOS)
        scaled.save(os.path.join(res_folder, "ic_launcher.png"), format="PNG")
        print(f"Saved {folder}/ic_launcher.png ({dim}x{dim})")

def draw_feature_graphic():
    width, height = 1024, 500
    base = Image.new("RGBA", (width, height), (15, 23, 42, 255))
    draw = ImageDraw.Draw(base)
    
    # Diagonal luxury gradient mesh
    for y in range(height):
        frac_y = y / height
        for x in range(0, width, 4):
            frac_x = x / width
            # Blend from deep dark blue-black #0B0F19 to indigo #312E81 to subtle violet #4C1D95
            r = int(11 * (1 - frac_x) + (49 * frac_y + 76 * (1 - frac_y)) * frac_x)
            g = int(15 * (1 - frac_x) + (46 * frac_y + 29 * (1 - frac_y)) * frac_x)
            b = int(25 * (1 - frac_x) + (129 * frac_y + 149 * (1 - frac_y)) * frac_x)
            draw.rectangle([x, y, x + 4, y + 1], fill=(r, g, b, 255))
            
    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay)
    
    # Ambient glows
    # Left ambient cyan glow
    for r in range(250, 0, -5):
        alpha = int(28 * (1 - r / 250))
        odraw.ellipse([160 - r, 250 - r, 160 + r, 250 + r], fill=(56, 189, 248, alpha))
        
    # Right ambient violet glow
    for r in range(320, 0, -5):
        alpha = int(32 * (1 - r / 320))
        odraw.ellipse([800 - r, 250 - r, 800 + r, 250 + r], fill=(139, 92, 246, alpha))
        
    # Mockup card on the right (sleek glassmorphic mobile mockup)
    card_x0, card_y0 = 620, 45
    card_x1, card_y1 = 940, 455
    # Glassmorphic card surface
    odraw.rounded_rectangle([card_x0, card_y0, card_x1, card_y1], radius=32, fill=(30, 41, 59, 220), outline=(255, 255, 255, 50), width=2)
    
    # Inside card: Time Box circle
    mock_cx = (card_x0 + card_x1) / 2
    mock_cy = card_y0 + 155
    odraw.ellipse([mock_cx - 90, mock_cy - 90, mock_cx + 90, mock_cy + 90], outline=(255, 255, 255, 30), width=8)
    
    # Glowing progress
    for deg in range(0, 240):
        rad = math.radians(deg - 90)
        t = deg / 240.0
        r = int(56 * (1 - t) + 168 * t)
        g = int(189 * (1 - t) + 85 * t)
        b = int(248 * (1 - t) + 247 * t)
        rx = mock_cx + 90 * math.cos(rad)
        ry = mock_cy + 90 * math.sin(rad)
        odraw.ellipse([rx - 4, ry - 4, rx + 4, ry + 4], fill=(r, g, b, 255))
        
    # Mock time text inside circle: "24:50"
    # Draw simple stylized digital numbers or lines
    odraw.rectangle([mock_cx - 45, mock_cy - 12, mock_cx + 45, mock_cy + 12], fill=(255, 255, 255, 230))
    odraw.rectangle([mock_cx - 30, mock_cy + 22, mock_cx + 30, mock_cy + 30], fill=(56, 189, 248, 200))
    
    # 2 micro-habit pill bars inside card
    odraw.rounded_rectangle([card_x0 + 25, mock_cy + 115, card_x1 - 25, mock_cy + 165], radius=16, fill=(51, 65, 85, 200), outline=(255, 255, 255, 30))
    odraw.ellipse([card_x0 + 40, mock_cy + 128, card_x0 + 64, mock_cy + 152], fill=(16, 185, 129, 255))
    odraw.rectangle([card_x0 + 75, mock_cy + 134, card_x0 + 210, mock_cy + 146], fill=(255, 255, 255, 220))
    
    odraw.rounded_rectangle([card_x0 + 25, mock_cy + 180, card_x1 - 25, mock_cy + 230], radius=16, fill=(51, 65, 85, 200), outline=(255, 255, 255, 30))
    odraw.ellipse([card_x0 + 40, mock_cy + 193, card_x0 + 64, mock_cy + 217], fill=(59, 130, 246, 255))
    odraw.rectangle([card_x0 + 75, mock_cy + 199, card_x0 + 190, mock_cy + 211], fill=(255, 255, 255, 220))
    
    # Left side: Typography & Branding
    # Try loading a system font or default font
    try:
        font_badge = ImageFont.truetype("arialbd.ttf", 20)
        font_title = ImageFont.truetype("arialbd.ttf", 52)
        font_subtitle = ImageFont.truetype("arial.ttf", 26)
        font_tag = ImageFont.truetype("arialbd.ttf", 18)
    except Exception:
        font_badge = ImageFont.load_default()
        font_title = font_badge
        font_subtitle = font_badge
        font_tag = font_badge
        
    # Badge: "DAILY ROUTINE & POMODORO FLOW"
    badge_x0, badge_y0 = 70, 75
    badge_x1, badge_y1 = 430, 115
    odraw.rounded_rectangle([badge_x0, badge_y0, badge_x1, badge_y1], radius=20, fill=(79, 70, 229, 90), outline=(99, 102, 241, 180), width=1)
    odraw.text((badge_x0 + 20, badge_y0 + 9), "DAILY ROUTINE & POMODORO FLOW", fill=(199, 210, 254, 255), font=font_badge)
    
    # Title: FocusTime Routine
    odraw.text((70, 140), "FocusTime Routine", fill=(255, 255, 255, 255), font=font_title)
    
    # Subtitle: Master your day with high-value micro-habits,
    # time-boxing flow, and ambient soundscapes.
    odraw.text((70, 215), "Master your daily micro-habits, flow state\n& time-boxing with ambient soundscapes.", fill=(203, 213, 225, 240), font=font_subtitle)
    
    # Feature highlight pills:
    features = [
        ("⚡ Time-Boxed Pomodoro", (99, 102, 241)),
        ("🎵 Ambient Soundscapes", (56, 189, 248)),
        ("🔒 100% Offline SQLite", (16, 185, 129)),
        ("✨ Fluid Spring Physics", (245, 158, 11))
    ]
    
    pill_x = 70
    pill_y = 330
    for label, col in features[:2]:
        odraw.rounded_rectangle([pill_x, pill_y, pill_x + 225, pill_y + 44], radius=22, fill=(30, 41, 59, 210), outline=col, width=1)
        odraw.text((pill_x + 18, pill_y + 12), label, fill=(241, 245, 249, 255), font=font_tag)
        pill_x += 245
        
    pill_x = 70
    pill_y = 390
    for label, col in features[2:]:
        odraw.rounded_rectangle([pill_x, pill_y, pill_x + 225, pill_y + 44], radius=22, fill=(30, 41, 59, 210), outline=col, width=1)
        odraw.text((pill_x + 18, pill_y + 12), label, fill=(241, 245, 249, 255), font=font_tag)
        pill_x += 245
        
    combined = Image.alpha_composite(base, overlay)
    out_feat = os.path.join(STORE_DIR, "feature_graphic.png")
    combined.save(out_feat, format="PNG")
    print(f"Saved {out_feat}")

if __name__ == "__main__":
    print("Generating store listing graphics and app icons...")
    draw_icon_512()
    draw_feature_graphic()
    print("Done!")
