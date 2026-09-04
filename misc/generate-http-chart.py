#!/usr/bin/env python3
"""Generate misc/valk-http.svg and misc/valk-http-dark.svg for the README.

Usage: python3 misc/generate-http-chart.py misc
Edit DATA with the new medians from examples/bench/http and rerun."""
import sys

# Median of 3 runs, 4 worker threads pinned to 4 cores, wrk on 8 other cores.
DATA = [
    ("Valk", "http", 6_455_170),
    ("Rust", "hyper 1.11 on tokio 1.53", 5_067_694),
    ("Go", "fasthttp 1.73", 3_443_542),
]

THEMES = {
    "light": dict(surface="#fcfcfb", text="#0b0b0b", text2="#52514e", muted="#898781",
                  grid="#e1e0d9", accent="#2a78d6", other="#c3c2b7"),
    "dark": dict(surface="#1a1a19", text="#ffffff", text2="#c3c2b7", muted="#898781",
                 grid="#2c2c2a", accent="#3987e5", other="#4a4a47"),
}

W, H = 900, 400
LEFT, RIGHT, TOP = 40, 40, 116
BAR_H, BAND = 24, 72
MAXV = 7_000_000
PLOT_W = W - LEFT - RIGHT
FONT = "-apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif"


def fmt(v):
    return f"{v / 1e6:.2f}M req/s"


def svg(theme):
    c = THEMES[theme]
    out = []
    out.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" '
               f'font-family="{FONT}" role="img" aria-label="HTTP hello-world benchmark: requests per second" xml:space="preserve">')
    out.append(f'<rect width="{W}" height="{H}" rx="12" fill="{c["surface"]}"/>')
    # Title
    out.append(f'<text x="{LEFT}" y="44" font-size="22" font-weight="600" fill="{c["text"]}">HTTP benchmarks - plain text</text>')
    out.append(f'<text x="{LEFT}" y="70" font-size="14" fill="{c["text2"]}">'
               f'Requests per second, higher is better. 4 worker threads each, pinned to 4 cores; '
               f'wrk on 8 other cores</text>')
    out.append(f'<text x="{LEFT}" y="90" font-size="14" fill="{c["text2"]}">'
               f'900 keep-alive connections, 16 pipelined requests, median of 3 x 5 s runs</text>')
    # Gridlines every 1M
    base_y = TOP + len(DATA) * BAND
    for m in range(0, MAXV + 1, 1_000_000):
        x = LEFT + PLOT_W * m / MAXV
        out.append(f'<line x1="{x:.1f}" y1="{TOP - 8}" x2="{x:.1f}" y2="{base_y}" stroke="{c["grid"]}" stroke-width="1"/>')
        label = "0" if m == 0 else f"{m // 1_000_000}M"
        anchor = "start" if m == 0 else "middle"
        out.append(f'<text x="{x:.1f}" y="{base_y + 18}" font-size="12" fill="{c["muted"]}" text-anchor="{anchor}">{label}</text>')
    # Bars
    for i, (name, lib, value) in enumerate(DATA):
        y = TOP + i * BAND
        w = PLOT_W * value / MAXV
        fill = c["accent"] if name == "Valk" else c["other"]
        # Rounded data end, square at the baseline: draw a rect then square off the left edge
        out.append(f'<rect x="{LEFT}" y="{y + 20}" width="{w:.1f}" height="{BAR_H}" rx="4" fill="{fill}"/>')
        out.append(f'<rect x="{LEFT}" y="{y + 20}" width="4" height="{BAR_H}" fill="{fill}"/>')
        out.append(f'<text x="{LEFT}" y="{y + 12}" font-size="15" font-weight="600" fill="{c["text"]}">{name} '
                   f'<tspan dx="6" font-weight="400" fill="{c["text2"]}">{lib}</tspan></text>')
        out.append(f'<text x="{LEFT + w + 10:.1f}" y="{y + 20 + BAR_H / 2 + 5}" font-size="14" fill="{c["text"]}">{fmt(value)}</text>')
    out.append(f'<text x="{LEFT}" y="{H - 18}" font-size="12" fill="{c["muted"]}">'
               f'Valk 0.5.1, Rust 1.97.1, Go 1.27.1</text>')
    out.append('</svg>')
    return "\n".join(out) + "\n"


if __name__ == "__main__":
    outdir = sys.argv[1]
    open(f"{outdir}/valk-http.svg", "w").write(svg("light"))
    open(f"{outdir}/valk-http-dark.svg", "w").write(svg("dark"))
    print("written")
