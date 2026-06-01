"""
Generates simple, fully-original placeholder art for the prototype.
Run with: python3 scripts/generate_placeholders.py
Re-run any time you want to regenerate the placeholder assets.
"""
from PIL import Image, ImageDraw
import os
import math

ASSETS = os.path.join(os.path.dirname(__file__), "..", "assets")
os.makedirs(ASSETS, exist_ok=True)


def save(img, name):
    path = os.path.join(ASSETS, name)
    img.save(path)
    print("wrote", os.path.relpath(path))


def rounded(draw, box, radius, fill):
    draw.rounded_rectangle(box, radius=radius, fill=fill)


# --- Player: a friendly teal blob (32 x 48) ---
p = Image.new("RGBA", (32, 48), (0, 0, 0, 0))
d = ImageDraw.Draw(p)
rounded(d, (2, 4, 29, 47), 12, (38, 198, 218, 255))      # body
rounded(d, (2, 4, 29, 26), 12, (77, 208, 225, 255))      # lighter head area
d.ellipse((9, 14, 15, 20), fill=(20, 20, 30, 255))       # left eye
d.ellipse((19, 14, 25, 20), fill=(20, 20, 30, 255))      # right eye
d.ellipse((11, 15, 13, 17), fill=(255, 255, 255, 255))   # eye shine
d.ellipse((21, 15, 23, 17), fill=(255, 255, 255, 255))
d.arc((11, 20, 21, 28), 20, 160, fill=(20, 20, 30, 255), width=2)  # smile
save(p, "player_placeholder.png")

# --- Ground tile (32 x 32) tileable-ish ---
g = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
d = ImageDraw.Draw(g)
d.rectangle((0, 0, 31, 31), fill=(120, 85, 60, 255))     # dirt
d.rectangle((0, 0, 31, 8), fill=(96, 200, 96, 255))      # grass top
d.rectangle((0, 8, 31, 10), fill=(70, 160, 70, 255))     # grass shadow
for x in range(2, 32, 8):                                 # dirt specks
    d.point((x, 18), fill=(90, 62, 42, 255))
    d.point((x + 3, 24), fill=(90, 62, 42, 255))
save(g, "ground_tile.png")

# --- Floating platform (96 x 24) ---
pf = Image.new("RGBA", (96, 24), (0, 0, 0, 0))
d = ImageDraw.Draw(pf)
rounded(d, (0, 0, 95, 23), 8, (120, 85, 60, 255))
rounded(d, (0, 0, 95, 9), 8, (96, 200, 96, 255))
save(pf, "platform.png")

# --- Coin (16 x 16) ---
c = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
d = ImageDraw.Draw(c)
d.ellipse((1, 1, 14, 14), fill=(255, 205, 60, 255))
d.ellipse((4, 4, 11, 11), fill=(255, 230, 120, 255))
save(c, "coin_placeholder.png")

# --- Sky background gradient (320 x 180) ---
bg = Image.new("RGBA", (320, 180), (0, 0, 0, 0))
for y in range(180):
    t = y / 179
    r = int(135 + (255 - 135) * t * 0.4)
    gg = int(206 + (240 - 206) * t * 0.4)
    b = int(250 - (250 - 200) * t * 0.4)
    for x in range(320):
        bg.putpixel((x, y), (r, gg, b, 255))
save(bg, "sky_background.png")

# --- Bird enemy (28 x 20) ---
bird = Image.new("RGBA", (28, 20), (0, 0, 0, 0))
d = ImageDraw.Draw(bird)
d.polygon([(2, 8), (9, 5), (9, 13)], fill=(90, 66, 150, 255))     # tail
d.ellipse((5, 6, 22, 16), fill=(124, 92, 200, 255))              # body
d.ellipse((16, 2, 27, 12), fill=(124, 92, 200, 255))            # head
d.polygon([(8, 9), (16, 1), (16, 11)], fill=(160, 128, 225, 255))  # wing
d.polygon([(25, 6), (28, 8), (25, 10)], fill=(255, 170, 60, 255))  # beak
d.ellipse((20, 5, 23, 8), fill=(20, 20, 30, 255))               # eye
save(bird, "bird.png")

# --- Walker / ground enemy (28 x 24) ---
w = Image.new("RGBA", (28, 24), (0, 0, 0, 0))
d = ImageDraw.Draw(w)
rounded(d, (2, 4, 25, 23), 8, (220, 90, 90, 255))                # red body
d.ellipse((7, 9, 13, 15), fill=(255, 255, 255, 255))             # eye whites
d.ellipse((15, 9, 21, 15), fill=(255, 255, 255, 255))
d.ellipse((9, 11, 12, 14), fill=(20, 20, 30, 255))               # pupils
d.ellipse((17, 11, 20, 14), fill=(20, 20, 30, 255))
d.rectangle((5, 20, 10, 23), fill=(60, 40, 40, 255))             # feet
d.rectangle((17, 20, 22, 23), fill=(60, 40, 40, 255))
save(w, "walker.png")

# --- Spike obstacle (24 x 16) ---
sp = Image.new("RGBA", (24, 16), (0, 0, 0, 0))
d = ImageDraw.Draw(sp)
for i in range(3):
    x = i * 8
    d.polygon([(x, 16), (x + 4, 1), (x + 8, 16)], fill=(170, 180, 200, 255))
    d.polygon([(x + 4, 1), (x + 8, 16), (x + 4, 16)], fill=(120, 130, 150, 255))
save(sp, "spike.png")

# --- Star collectible (20 x 20) ---
st = Image.new("RGBA", (20, 20), (0, 0, 0, 0))
d = ImageDraw.Draw(st)
cx, cy, outer, inner = 10, 10, 9, 4
pts = []
for i in range(10):
    ang = -math.pi / 2 + i * math.pi / 5
    rad = outer if i % 2 == 0 else inner
    pts.append((cx + rad * math.cos(ang), cy + rad * math.sin(ang)))
d.polygon(pts, fill=(255, 215, 70, 255))
d.polygon([(p[0], p[1]) for p in pts[:6]], fill=(255, 235, 140, 255))
save(st, "star.png")

# --- Power-up (22 x 22) ---
pu = Image.new("RGBA", (22, 22), (0, 0, 0, 0))
d = ImageDraw.Draw(pu)
rounded(d, (6, 11, 16, 21), 4, (255, 236, 200, 255))             # stem
d.ellipse((1, 2, 21, 16), fill=(255, 110, 150, 255))            # cap
d.ellipse((6, 5, 10, 9), fill=(255, 255, 255, 235))            # spots
d.ellipse((13, 7, 17, 11), fill=(255, 255, 255, 235))
save(pu, "powerup.png")

# --- Parallax: far mountains (640 x 180) ---
mt = Image.new("RGBA", (640, 180), (0, 0, 0, 0))
d = ImageDraw.Draw(mt)
d.polygon([(0, 180), (120, 70), (240, 180)], fill=(120, 140, 200, 255))
d.polygon([(180, 180), (340, 50), (500, 180)], fill=(100, 120, 185, 255))
d.polygon([(420, 180), (560, 80), (640, 180)], fill=(110, 130, 195, 255))
save(mt, "bg_mountains.png")

# --- Parallax: hills (640 x 160) ---
hl = Image.new("RGBA", (640, 160), (0, 0, 0, 0))
d = ImageDraw.Draw(hl)
d.ellipse((-100, 70, 200, 320), fill=(90, 180, 110, 255))
d.ellipse((180, 90, 460, 340), fill=(80, 165, 100, 255))
d.ellipse((420, 70, 760, 320), fill=(95, 185, 115, 255))
save(hl, "bg_hills.png")

# --- Parallax: clouds (640 x 120, transparent) ---
cl = Image.new("RGBA", (640, 120), (0, 0, 0, 0))
d = ImageDraw.Draw(cl)


def cloud(x, y, s):
    x, y = int(x), int(y)
    d.ellipse((x, y, int(x + 40 * s), int(y + 24 * s)), fill=(255, 255, 255, 220))
    d.ellipse((int(x + 20 * s), int(y - 10 * s), int(x + 70 * s), int(y + 24 * s)), fill=(255, 255, 255, 220))
    d.ellipse((int(x + 45 * s), y, int(x + 90 * s), int(y + 24 * s)), fill=(255, 255, 255, 220))


cloud(40, 35, 1.0)
cloud(300, 55, 1.3)
cloud(500, 28, 0.9)
save(cl, "bg_clouds.png")

# --- Touch button (96 x 96, translucent) ---
tb = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
d = ImageDraw.Draw(tb)
d.ellipse((4, 4, 92, 92), fill=(255, 255, 255, 60), outline=(255, 255, 255, 170), width=4)
save(tb, "touch_button.png")

# --- Goal flag (28 x 44) ---
fl = Image.new("RGBA", (28, 44), (0, 0, 0, 0))
d = ImageDraw.Draw(fl)
d.rectangle((4, 2, 7, 43), fill=(180, 180, 190, 255))           # pole
d.ellipse((1, 0, 9, 8), fill=(255, 215, 70, 255))               # gold topper
d.polygon([(7, 5), (26, 11), (7, 19)], fill=(80, 200, 120, 255))  # flag
save(fl, "flag.png")

# --- Checkpoint flag (20 x 44) ---
cp = Image.new("RGBA", (20, 44), (0, 0, 0, 0))
d = ImageDraw.Draw(cp)
d.rectangle((3, 2, 6, 43), fill=(150, 150, 160, 255))           # pole
d.polygon([(6, 6), (18, 11), (6, 16)], fill=(120, 160, 255, 255))  # blue flag (lit green when reached)
save(cp, "checkpoint.png")

# --- Spark particle (10 x 10) ---
spk = Image.new("RGBA", (10, 10), (0, 0, 0, 0))
d = ImageDraw.Draw(spk)
d.ellipse((1, 1, 9, 9), fill=(255, 255, 255, 255))
save(spk, "spark.png")

# --- Raindrop particle (6 x 12) ---
rd = Image.new("RGBA", (6, 12), (0, 0, 0, 0))
d = ImageDraw.Draw(rd)
d.ellipse((0, 0, 5, 11), fill=(180, 210, 255, 230))
save(rd, "raindrop.png")

# === Player animation frames (32 x 48 each) ===
PLAYER_DIR = os.path.join(ASSETS, "player")
os.makedirs(PLAYER_DIR, exist_ok=True)


def save_player(img, name):
    path = os.path.join(PLAYER_DIR, name)
    img.save(path)
    print("wrote", os.path.relpath(path))


def draw_lumi(body_box, head_ratio=0.5, eye_dx=0, eye_dy=0, hurt=False, mouth="smile"):
    """Draws Lumi inside body_box so different boxes give squash/stretch poses."""
    img = Image.new("RGBA", (32, 48), (0, 0, 0, 0))
    dd = ImageDraw.Draw(img)
    l, t, r, b = body_box
    rounded(dd, (l, t, r, b), 12, (38, 198, 218, 255))
    rounded(dd, (l, t, r, int(t + (b - t) * head_ratio)), 12, (77, 208, 225, 255))
    w = r - l
    ex1 = int(l + w * 0.26) + eye_dx
    ex2 = int(l + w * 0.58) + eye_dx
    ey = int(t + (b - t) * 0.28) + eye_dy
    if hurt:
        for cxp in (ex1, ex2):
            dd.line((cxp, ey, cxp + 6, ey + 6), fill=(20, 20, 30, 255), width=2)
            dd.line((cxp + 6, ey, cxp, ey + 6), fill=(20, 20, 30, 255), width=2)
    else:
        dd.ellipse((ex1, ey, ex1 + 6, ey + 6), fill=(20, 20, 30, 255))
        dd.ellipse((ex2, ey, ex2 + 6, ey + 6), fill=(20, 20, 30, 255))
        dd.ellipse((ex1 + 1, ey + 1, ex1 + 3, ey + 3), fill=(255, 255, 255, 255))
        dd.ellipse((ex2 + 1, ey + 1, ex2 + 3, ey + 3), fill=(255, 255, 255, 255))
    my = int(t + (b - t) * 0.52)
    if mouth == "smile":
        dd.arc((int(l + w * 0.30), my, int(l + w * 0.66), my + 8), 20, 160, fill=(20, 20, 30, 255), width=2)
    elif mouth == "open":
        dd.ellipse((int(l + w * 0.40), my, int(l + w * 0.58), my + 9), fill=(20, 20, 30, 255))
    return img


save_player(draw_lumi((2, 4, 29, 47)), "idle_0.png")
save_player(draw_lumi((3, 6, 28, 47)), "idle_1.png")
save_player(draw_lumi((2, 3, 29, 46), eye_dx=1), "run_0.png")
save_player(draw_lumi((2, 5, 29, 47), eye_dx=2), "run_1.png")
save_player(draw_lumi((2, 3, 29, 46), eye_dx=1), "run_2.png")
save_player(draw_lumi((2, 6, 29, 47), eye_dx=0), "run_3.png")
save_player(draw_lumi((4, 1, 27, 44), head_ratio=0.55, eye_dy=-1, mouth="open"), "jump_0.png")
save_player(draw_lumi((1, 8, 30, 47), head_ratio=0.45, mouth="open"), "fall_0.png")
save_player(draw_lumi((2, 6, 29, 45), eye_dx=3), "dash_0.png")
save_player(draw_lumi((2, 5, 29, 47), hurt=True, mouth="open"), "hurt_0.png")

print("Done.")
