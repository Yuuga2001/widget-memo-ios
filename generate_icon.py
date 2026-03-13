#!/usr/bin/env python3
"""Generate WidgetMemo app icon - 1024x1024 PNG."""
from PIL import Image, ImageDraw, ImageFont
import os

SIZE = 1024
OUT = os.path.join(
    os.path.dirname(__file__),
    "WidgetMemo", "Resources", "Assets.xcassets",
    "AppIcon.appiconset", "icon_1024.png",
)


def draw_rounded_rect(draw, bbox, radius, fill):
    """Draw a rounded rectangle."""
    x0, y0, x1, y1 = bbox
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)
    draw.pieslice([x0, y0, x0 + 2 * radius, y0 + 2 * radius], 180, 270, fill=fill)
    draw.pieslice([x1 - 2 * radius, y0, x1, y0 + 2 * radius], 270, 360, fill=fill)
    draw.pieslice([x0, y1 - 2 * radius, x0 + 2 * radius, y1], 90, 180, fill=fill)
    draw.pieslice([x1 - 2 * radius, y1 - 2 * radius, x1, y1], 0, 90, fill=fill)


def main():
    img = Image.new("RGB", (SIZE, SIZE), (255, 220, 80))
    draw = ImageDraw.Draw(img)

    # Warm yellow gradient background (sticky note feel)
    for y in range(SIZE):
        t = y / SIZE
        r = int(255 - t * 12)
        g = int(220 - t * 25)
        b = int(80 + t * 10)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b))

    # Subtle fold shadow in bottom-right corner
    fold_size = 160
    for i in range(fold_size):
        alpha = int(40 * (1 - i / fold_size))
        c = max(0, 255 - 30 - alpha)
        y = SIZE - fold_size + i
        draw.line([(SIZE - fold_size + i, y), (SIZE, y)], fill=(c, c - 20, c - 50))

    # Fold triangle (slightly darker)
    fold_pts = [
        (SIZE - fold_size, SIZE),
        (SIZE, SIZE - fold_size),
        (SIZE, SIZE),
    ]
    draw.polygon(fold_pts, fill=(230, 195, 60))

    # Horizontal ruled lines
    line_color = (220, 190, 60)
    for i in range(6):
        y = 260 + i * 110
        draw.line([(120, y), (900, y)], fill=line_color, width=3)

    # Pencil icon (simple geometric)
    pencil_x, pencil_y = 510, 480
    # Pencil body
    body_pts = [
        (pencil_x, pencil_y - 180),
        (pencil_x + 50, pencil_y - 180),
        (pencil_x + 50, pencil_y + 60),
        (pencil_x, pencil_y + 60),
    ]
    draw.polygon(body_pts, fill=(100, 100, 100))

    # Pencil tip
    tip_pts = [
        (pencil_x, pencil_y + 60),
        (pencil_x + 50, pencil_y + 60),
        (pencil_x + 25, pencil_y + 120),
    ]
    draw.polygon(tip_pts, fill=(60, 60, 60))

    # Pencil point
    point_pts = [
        (pencil_x + 10, pencil_y + 90),
        (pencil_x + 40, pencil_y + 90),
        (pencil_x + 25, pencil_y + 120),
    ]
    draw.polygon(point_pts, fill=(240, 200, 140))

    # Eraser
    eraser_pts = [
        (pencil_x, pencil_y - 180),
        (pencil_x + 50, pencil_y - 180),
        (pencil_x + 50, pencil_y - 140),
        (pencil_x, pencil_y - 140),
    ]
    draw.polygon(eraser_pts, fill=(230, 140, 140))

    # "Memo" text
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 160)
    except (OSError, IOError):
        try:
            font = ImageFont.truetype("/System/Library/Fonts/SFNSText.ttf", 160)
        except (OSError, IOError):
            font = ImageFont.load_default()

    text_color = (80, 60, 20)
    draw.text((140, 100), "Memo", fill=text_color, font=font)

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    img.save(OUT, "PNG")
    print(f"Icon saved: {OUT}")


if __name__ == "__main__":
    main()
