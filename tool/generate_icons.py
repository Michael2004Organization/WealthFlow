"""Draws the WealthFlow app icons from the same shape as AppLogo.

The points match `logoLinePoints` in lib/core/widgets/common_widgets.dart.
Run from the project root after changing the logo:

    python3 tool/generate_icons.py

Needs Pillow (pip install pillow).
"""

from pathlib import Path

from PIL import Image, ImageDraw

TILE = (0x0E, 0x6E, 0x66, 255)
LINE = (255, 255, 255, 255)
POINTS = [(.22, .66), (.40, .46), (.54, .58), (.78, .32)]
RADIUS = .28
STROKE = .085
SUPERSAMPLE = 8


def draw(size, *, full_bleed=False, margin=0.0):
    """A square icon. full_bleed fills the canvas (maskable icons) and draws
    the line inside the central safe zone; margin leaves transparent space
    around the rounded tile."""
    big = size * SUPERSAMPLE
    image = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    canvas = ImageDraw.Draw(image)
    if full_bleed:
        canvas.rectangle((0, 0, big, big), fill=TILE)
        inset, side = big * .1, big * .8
    else:
        inset = big * margin
        side = big - 2 * inset
        canvas.rounded_rectangle(
            (inset, inset, inset + side, inset + side),
            radius=side * RADIUS,
            fill=TILE,
        )
    width = side * STROKE
    points = [(inset + x * side, inset + y * side) for x, y in POINTS]
    canvas.line(points, fill=LINE, width=round(width), joint='curve')
    for x, y in (points[0], points[-1]):
        r = width / 2
        canvas.ellipse((x - r, y - r, x + r, y + r), fill=LINE)
    return image.resize((size, size), Image.LANCZOS)


def main():
    root = Path(__file__).resolve().parent.parent
    for folder, size in {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
    }.items():
        draw(size, margin=.04).save(
            root / f'android/app/src/main/res/mipmap-{folder}/ic_launcher.png'
        )
    web = root / 'web'
    draw(32).save(web / 'favicon.png')
    for size in (192, 512):
        draw(size).save(web / f'icons/Icon-{size}.png')
        draw(size, full_bleed=True).save(web / f'icons/Icon-maskable-{size}.png')
    draw(256).save(
        root / 'windows/runner/resources/app_icon.ico',
        sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (256, 256)],
    )


if __name__ == '__main__':
    main()
