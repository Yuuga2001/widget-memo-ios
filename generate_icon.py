#!/usr/bin/env python3
"""Generate WidgetMemo app icon - 1024x1024 PNG.

Design concept: A widget card floating on a gradient background,
with handwritten-style memo text lines on it, and a small pencil
writing on the widget. Conveys "memo on a widget" at a glance.
"""
from PIL import Image, ImageDraw, ImageFont
import math
import os

SIZE = 1024
OUT = os.path.join(
    os.path.dirname(__file__),
    "WidgetMemo", "Resources", "Assets.xcassets",
    "AppIcon.appiconset", "icon_1024.png",
)


def draw_rounded_rect(draw, bbox, radius, fill, outline=None, outline_width=0):
    """Draw a rounded rectangle with optional outline."""
    x0, y0, x1, y1 = bbox
    # Fill
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)
    draw.pieslice([x0, y0, x0 + 2 * radius, y0 + 2 * radius], 180, 270, fill=fill)
    draw.pieslice([x1 - 2 * radius, y0, x1, y0 + 2 * radius], 270, 360, fill=fill)
    draw.pieslice([x0, y1 - 2 * radius, x0 + 2 * radius, y1], 90, 180, fill=fill)
    draw.pieslice([x1 - 2 * radius, y1 - 2 * radius, x1, y1], 0, 90, fill=fill)
    # Outline
    if outline and outline_width > 0:
        draw.arc([x0, y0, x0 + 2 * radius, y0 + 2 * radius], 180, 270, fill=outline, width=outline_width)
        draw.arc([x1 - 2 * radius, y0, x1, y0 + 2 * radius], 270, 360, fill=outline, width=outline_width)
        draw.arc([x0, y1 - 2 * radius, x0 + 2 * radius, y1], 90, 180, fill=outline, width=outline_width)
        draw.arc([x1 - 2 * radius, y1 - 2 * radius, x1, y1], 0, 90, fill=outline, width=outline_width)
        draw.line([(x0 + radius, y0), (x1 - radius, y0)], fill=outline, width=outline_width)
        draw.line([(x0 + radius, y1), (x1 - radius, y1)], fill=outline, width=outline_width)
        draw.line([(x0, y0 + radius), (x0, y1 - radius)], fill=outline, width=outline_width)
        draw.line([(x1, y0 + radius), (x1, y1 - radius)], fill=outline, width=outline_width)


def draw_pencil(draw, cx, cy, length, angle_deg, body_color, tip_color, eraser_color):
    """Draw a pencil at given center, rotated by angle."""
    angle = math.radians(angle_deg)
    cos_a, sin_a = math.cos(angle), math.sin(angle)

    def rot(x, y):
        return (cx + x * cos_a - y * sin_a, cy + x * sin_a + y * cos_a)

    half = length / 2
    w = 28  # half-width of pencil body

    # Body
    body = [rot(-half, -w), rot(-half, w), rot(half * 0.55, w), rot(half * 0.55, -w)]
    draw.polygon(body, fill=body_color)

    # Stripe on body
    s1 = [rot(-half * 0.1, -w), rot(-half * 0.1, w), rot(half * 0.15, w), rot(half * 0.15, -w)]
    draw.polygon(s1, fill=(min(body_color[0] + 30, 255), min(body_color[1] + 30, 255), body_color[2]))

    # Metal ferrule
    ferrule = [rot(half * 0.55, -w), rot(half * 0.55, w), rot(half * 0.68, w), rot(half * 0.68, -w)]
    draw.polygon(ferrule, fill=(180, 180, 170))

    # Tip (triangle)
    tip = [rot(half * 0.68, -w), rot(half * 0.68, w), rot(half, 0)]
    draw.polygon(tip, fill=tip_color)

    # Tip point
    tip_point = [rot(half * 0.82, -w * 0.45), rot(half * 0.82, w * 0.45), rot(half, 0)]
    draw.polygon(tip_point, fill=(60, 50, 30))

    # Eraser
    eraser = [rot(-half, -w), rot(-half, w), rot(-half * 0.82, w), rot(-half * 0.82, -w)]
    draw.polygon(eraser, fill=eraser_color)


def main():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # === Background: soft warm gradient ===
    for y in range(SIZE):
        t = y / SIZE
        r = int(255 - t * 30)
        g = int(175 - t * 45)
        b = int(95 + t * 30)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

    # === Shadow under widget card ===
    shadow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    draw_rounded_rect(shadow_draw, (108, 118, 778, 838), 52, (0, 0, 0, 60))
    img = Image.alpha_composite(img, shadow_layer)
    draw = ImageDraw.Draw(img)

    # === Widget card (white, rounded corners like iOS widget) ===
    card_x0, card_y0, card_x1, card_y1 = 95, 100, 765, 820
    card_radius = 48
    draw_rounded_rect(draw, (card_x0, card_y0, card_x1, card_y1), card_radius, (255, 255, 255, 255))

    # Subtle inner border
    draw_rounded_rect(draw, (card_x0, card_y0, card_x1, card_y1), card_radius,
                      fill=None, outline=(230, 230, 230, 255), outline_width=2)

    # === Memo text lines on the widget ===
    try:
        font_text = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 42)
    except (OSError, IOError):
        try:
            font_text = ImageFont.truetype("/System/Library/Fonts/SFNSText.ttf", 42)
        except (OSError, IOError):
            font_text = ImageFont.load_default()

    try:
        font_text_sm = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
    except (OSError, IOError):
        try:
            font_text_sm = ImageFont.truetype("/System/Library/Fonts/SFNSText.ttf", 36)
        except (OSError, IOError):
            font_text_sm = ImageFont.load_default()

    # Handwritten-feel memo lines (dark gray text)
    text_color = (60, 60, 65, 255)
    text_light = (140, 140, 150, 255)
    memo_x = card_x0 + 55
    memo_y_start = card_y0 + 50

    lines = [
        ("Buy milk", text_color, font_text),
        ("Meeting at 3pm", text_color, font_text),
        ("Call dentist", text_color, font_text),
        ("Read chapter 5", text_light, font_text_sm),
        ("Grocery list...", text_light, font_text_sm),
    ]

    for i, (text, color, font) in enumerate(lines):
        y = memo_y_start + i * 75
        draw.text((memo_x, y), text, fill=color, font=font)
        # Subtle underline (notebook ruled line)
        line_y = y + 58
        draw.line([(memo_x - 10, line_y), (card_x1 - 50, line_y)],
                  fill=(220, 220, 225, 180), width=1)

    # === Dotted lines for remaining space (empty lines) ===
    for i in range(2):
        y = memo_y_start + (len(lines) + i) * 75 + 58
        draw.line([(memo_x - 10, y), (card_x1 - 50, y)],
                  fill=(230, 230, 235, 140), width=1)

    # === Pencil overlaying the card (writing gesture) ===
    draw_pencil(
        draw,
        cx=680, cy=750,
        length=400,
        angle_deg=-50,
        body_color=(255, 195, 60),
        tip_color=(220, 185, 130),
        eraser_color=(230, 120, 120),
    )

    # === Small dot at pencil tip (ink mark) ===
    draw.ellipse([(728, 614), (738, 624)], fill=(50, 50, 55, 200))

    # Convert to RGB for final PNG
    final = Image.new("RGB", (SIZE, SIZE), (255, 175, 95))
    final.paste(img, (0, 0), img)

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    final.save(OUT, "PNG")
    print(f"Icon saved: {OUT}")


if __name__ == "__main__":
    main()
