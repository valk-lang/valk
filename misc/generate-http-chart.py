#!/usr/bin/env python3
"""Generate misc/valk-http.svg and misc/valk-http-dark.svg for the README.

Usage: python3 misc/generate-http-chart.py misc
Edit DATA with the new medians from examples/bench/http and rerun.
"""
import sys
from html import escape
from pathlib import Path

# Median of 3 runs, 4 worker threads pinned to 4 cores, wrk on 8 other cores.
DATA = [
    ("Valk", "http", 6_455_170),
    ("Rust", "hyper 1.11 on tokio 1.53", 5_067_694),
    ("Go", "fasthttp 1.73", 3_443_542),
]

# Dark colors follow https://valk-lang.dev/assets/site.css; light adapts the same palette.
THEMES = {
    "light": dict(surface="#ffffff", text="#101121", muted="#52617a",
                  border="#dce3ee", track="#edf1f8", accent="#1268ff", other="#42618c",
                  value="#34445f"),
    "dark": dict(surface="#04060b", text="#f1f1f7", muted="#b2b4c6",
                 border="#202c45", track="#101726", accent="#1268ff", other="#42618c",
                 value="#c1c5d4"),
}

W, H = 900, 400
LEFT, RIGHT, TOP = 32, 32, 140
BAR_H, BAND = 12, 60
MAXV = 7_000_000
PLOT_W = W - LEFT - RIGHT
FONT = "Arial, Helvetica, sans-serif"
MONO = "ui-monospace, SFMono-Regular, Consolas, 'Liberation Mono', monospace"


def fmt(v):
    return f"{v / 1e6:.2f}M req/s"


def svg(theme):
    c = THEMES[theme]
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
           f'viewBox="0 0 {W} {H}" font-family="{FONT}" role="img" '
           'aria-labelledby="title description">',
           '<title id="title">HTTP hello-world benchmark</title>',
           '<desc id="description">' + escape('; '.join(
               f'{name} {lib}: {value:,} requests per second' for name, lib, value in DATA
           )) + '. Higher is better.</desc>',
           f'<rect x="0.5" y="0.5" width="{W - 1}" height="{H - 1}" rx="7" '
           f'fill="{c["surface"]}" stroke="{c["border"]}"/>']

    def text(x, y, content, color, size=14, font=FONT, anchor="start", weight=400):
        out.append(f'<text x="{x}" y="{y}" font-size="{size}" font-family="{font}" '
                   f'font-weight="{weight}" fill="{color}" text-anchor="{anchor}">'
                   f'{escape(content)}</text>')

    def divider(y):
        out.append(f'<path d="M 1 {y} H {W - 1}" stroke="{c["border"]}"/>')

    text(LEFT, 39, "HTTP benchmarks", c["text"], size=18, weight=500)
    text(W - RIGHT, 38, "Valk 0.6.0", c["muted"], font=MONO, anchor="end")
    divider(64)
    text(LEFT, 98, "HTTP hello world · req/s", c["muted"], font=MONO)
    text(W - RIGHT, 98, "Higher is better", c["muted"], font=MONO, anchor="end")

    for i, (name, lib, value) in enumerate(DATA):
        y = TOP + i * BAND
        text(LEFT, y, name, c["text"], size=15, weight=600)
        text(LEFT + 56, y, lib, c["muted"], size=13)
        text(W - RIGHT, y, fmt(value), c["value"], font=MONO, anchor="end")
        out.append(f'<rect x="{LEFT}" y="{y + 14}" width="{PLOT_W}" height="{BAR_H}" '
                   f'rx="2" fill="{c["track"]}"/>')
        fill = c["accent"] if name == "Valk" else c["other"]
        out.append(f'<rect x="{LEFT}" y="{y + 14}" width="{PLOT_W * value / MAXV:.1f}" '
                   f'height="{BAR_H}" rx="2" fill="{fill}"/>')

    divider(312)
    text(LEFT, 338, "4 workers pinned to 4 cores; wrk on 8 other cores.", c["muted"], size=13)
    text(LEFT, 360, "900 keep-alive connections · 16 pipelined requests · Median of three 5-second runs.",
         c["muted"], size=13)
    text(LEFT, 382, "Valk 0.6.0 · Rust 1.97.1 · Go 1.27.1", c["muted"], size=12, font=MONO)
    out.append('</svg>')
    return "\n".join(out) + "\n"


if __name__ == "__main__":
    outdir = Path(sys.argv[1])
    for theme, suffix in (("light", ""), ("dark", "-dark")):
        (outdir / f"valk-http{suffix}.svg").write_text(svg(theme), encoding="utf-8")
    print("written")
