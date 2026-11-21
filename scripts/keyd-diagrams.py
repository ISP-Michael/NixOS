#!/usr/bin/env python3
"""Render keyd layer diagrams from host/hardware/keyd/default.conf.

The keyboard layout is the standard ANSI 60% grid; keys that a layer does not
touch stay dim. Output is SVG; convert to PNG with Inkscape.
"""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CONF = ROOT / "host/hardware/keyd/default.conf"
OUT = ROOT / "docs/images"

UNIT = 64
GAP = 8
MARGIN = 48

# ANSI rows: (keyd name, width in units, display label)
ROWS = [
    [
        ("`", 1, "`"), ("1", 1, "1"), ("2", 1, "2"), ("3", 1, "3"),
        ("4", 1, "4"), ("5", 1, "5"), ("6", 1, "6"), ("7", 1, "7"),
        ("8", 1, "8"), ("9", 1, "9"), ("0", 1, "0"), ("-", 1, "-"),
        ("=", 1, "="), ("backspace", 2, "Bksp"),
    ],
    [
        ("tab", 1.5, "Tab"), ("q", 1, "Q"), ("w", 1, "W"), ("e", 1, "E"),
        ("r", 1, "R"), ("t", 1, "T"), ("y", 1, "Y"), ("u", 1, "U"),
        ("i", 1, "I"), ("o", 1, "O"), ("p", 1, "P"), ("[", 1, "["),
        ("]", 1, "]"), ("\\", 1.5, "\\"),
    ],
    [
        ("capslock", 1.75, "Caps"), ("a", 1, "A"), ("s", 1, "S"),
        ("d", 1, "D"), ("f", 1, "F"), ("g", 1, "G"), ("h", 1, "H"),
        ("j", 1, "J"), ("k", 1, "K"), ("l", 1, "L"), (";", 1, ";"),
        ("'", 1, "'"), ("enter", 2.25, "Enter"),
    ],
    [
        ("leftshift", 2.25, "Shift"), ("z", 1, "Z"), ("x", 1, "X"),
        ("c", 1, "C"), ("v", 1, "V"), ("b", 1, "B"), ("n", 1, "N"),
        ("m", 1, "M"), (",", 1, ","), (".", 1, "."), ("/", 1, "/"),
        ("rightshift", 2.75, "Shift"),
    ],
    [
        ("leftcontrol", 1.25, "Ctrl"), ("leftmeta", 1.25, "Meta"),
        ("leftalt", 1.25, "Alt"), ("space", 6.25, "Space"),
        ("rightalt", 1.25, "Alt"), ("rightmeta", 1.25, "Meta"),
        ("menu", 1.25, "Menu"), ("rightcontrol", 1.25, "Ctrl"),
    ],
]

COLORS = {
    "bg": "#1e1f22",
    "key": "#26282c",
    "mapped": "#3b4a6b",
    "stroke": "#7aa2f7",
    "dim": "#6b6f78",
    "text": "#e6e6e6",
    "label": "#9aa5b1",
}

# Short labels for keyd actions that do not fit on a key.
ACTIONS = {
    "left": "←",
    "right": "→",
    "up": "↑",
    "down": "↓",
    "escape": "Esc",
    "backspace": "Bksp",
    "delete": "Del",
    "enter": "Enter",
    "tab": "Tab",
    "brightnessdown": "Bri-",
    "brightnessup": "Bri+",
    "mute": "Mute",
    "volumedown": "Vol-",
    "volumeup": "Vol+",
    "sysrq": "SysRq",
    "layer(lalt_shift)": "⇧ слой",
}

TITLES = {
    "lalt_layer": "keyd: левый Alt (тап) — навигация и медиа",
    "ralt_layer": "keyd: правый Alt (тап) — цифры, символы, F-клавиши",
    "lalt_shift": "keyd: левый Alt + / — буквы с Shift",
}

FOOTNOTE = "источник: host/hardware/keyd/default.conf · timeout 200 мс"


def parse_conf(path: pathlib.Path) -> dict[str, dict[str, str]]:
    layers: dict[str, dict[str, str]] = {}
    current: str | None = None
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        section = re.fullmatch(r"\[([^\]]+)\]", line)
        if section:
            current = section.group(1)
            layers[current] = {}
            continue
        if current and "=" in line:
            key, value = line.split("=", 1)
            layers[current][key.strip()] = value.strip()
    return layers


def action_label(value: str) -> str:
    if value in ACTIONS:
        return ACTIONS[value]
    if value.startswith("S-") and len(value) == 3:
        return "⇧" + value[2].upper()
    return value


def key_rect(x: float, y: float, width: float, height: float, mapped: bool) -> str:
    fill = COLORS["mapped"] if mapped else COLORS["key"]
    stroke = COLORS["stroke"] if mapped else "#33363b"
    return (
        f'<rect x="{x:.1f}" y="{y:.1f}" width="{width:.1f}" height="{height:.1f}" '
        f'rx="9" fill="{fill}" stroke="{stroke}" stroke-width="1.5"/>'
    )


def text(x: float, y: float, value: str, size: int, color: str, weight: str = "normal") -> str:
    value = (
        value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    )
    return (
        f'<text x="{x:.1f}" y="{y:.1f}" font-family="DejaVu Sans" '
        f'font-size="{size}" font-weight="{weight}" fill="{color}" '
        f'text-anchor="middle">{value}</text>'
    )


def render_layer(name: str, mapping: dict[str, str]) -> str:
    width = 15 * UNIT + 14 * GAP + 2 * MARGIN
    height = 5 * UNIT + 4 * GAP + 170
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}">',
        f'<rect width="{width}" height="{height}" fill="{COLORS["bg"]}"/>',
        f'<text x="{MARGIN}" y="46" font-family="DejaVu Sans" font-size="22" '
        f'font-weight="bold" fill="{COLORS["text"]}">{TITLES.get(name, name)}</text>',
    ]

    y = 78
    for row in ROWS:
        x = MARGIN
        for key, units, label in row:
            w = units * UNIT + (units - 1) * GAP
            mapped = key in mapping
            parts.append(key_rect(x, y, w, UNIT, mapped))
            parts.append(
                text(x + w / 2, y + 18, label, 11, COLORS["label"] if mapped else COLORS["dim"])
            )
            if mapped:
                value = action_label(mapping[key])
                size = 11 if len(value) > 6 else 16
                dy = 0 if len(value) <= 6 else 3
                parts.append(
                    text(x + w / 2, y + UNIT / 2 + 8 + dy, value, size, COLORS["text"], "bold")
                )
            x += w + GAP
        y += UNIT + GAP

    parts.append(
        f'<text x="{MARGIN}" y="{height - 28}" font-family="DejaVu Sans" '
        f'font-size="12" fill="{COLORS["dim"]}">{FOOTNOTE}</text>'
    )
    parts.append("</svg>")
    return "\n".join(parts)


def render_main(layers: dict[str, dict[str, str]]) -> str:
    width = 1168
    height = 360
    cards = [
        ("Left Alt", "тап → lalt_layer", "удержание → Alt"),
        ("Right Alt", "тап → ralt_layer", "удержание → Alt"),
        ("CapsLock", "тап → Ctrl", "удержание → CapsLock"),
    ]
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}">',
        f'<rect width="{width}" height="{height}" fill="{COLORS["bg"]}"/>',
        f'<text x="{MARGIN}" y="48" font-family="DejaVu Sans" font-size="24" '
        f'font-weight="bold" fill="{COLORS["text"]}">keyd: модификаторы и timeouts</text>',
    ]
    card_w = 330
    card_h = 150
    x = MARGIN
    for title, tap, hold in cards:
        parts.append(
            f'<rect x="{x}" y="90" width="{card_w}" height="{card_h}" rx="14" '
            f'fill="{COLORS["key"]}" stroke="{COLORS["stroke"]}" stroke-width="1.5"/>'
        )
        parts.append(
            f'<text x="{x + 24}" y="130" font-family="DejaVu Sans" font-size="20" '
            f'font-weight="bold" fill="{COLORS["text"]}">{title}</text>'
        )
        parts.append(
            f'<text x="{x + 24}" y="170" font-family="DejaVu Sans" font-size="15" '
            f'fill="{COLORS["label"]}">{tap}</text>'
        )
        parts.append(
            f'<text x="{x + 24}" y="200" font-family="DejaVu Sans" font-size="15" '
            f'fill="{COLORS["label"]}">{hold}</text>'
        )
        x += card_w + 32

    parts.append(
        f'<text x="{MARGIN}" y="{height - 34}" font-family="DejaVu Sans" '
        f'font-size="13" fill="{COLORS["dim"]}">{FOOTNOTE}</text>'
    )
    parts.append("</svg>")
    return "\n".join(parts)


def main() -> int:
    layers = parse_conf(CONF)
    OUT.mkdir(parents=True, exist_ok=True)

    (OUT / "keyd-main.svg").write_text(render_main(layers), encoding="utf-8")
    for layer in ("lalt_layer", "ralt_layer", "lalt_shift"):
        (OUT / f"keyd-{layer.replace('_', '-')}.svg").write_text(
            render_layer(layer, layers.get(layer, {})), encoding="utf-8"
        )
    print("wrote keyd diagrams to", OUT)
    return 0


if __name__ == "__main__":
    sys.exit(main())
