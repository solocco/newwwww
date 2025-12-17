#!/usr/bin/env python3
import sys, yaml

def hex_to_rgb(h):
    return tuple(int(h[i:i+2],16) for i in (1,3,5))

def rgb_to_hex(rgb):
    return '#{:02x}{:02x}{:02x}'.format(*rgb)

def lerp(a,b,t):
    return (
        int(a[0] + (b[0] - a[0]) * t),
        int(a[1] + (b[1] - a[1]) * t),
        int(a[2] + (b[2] - a[2]) * t)
    )

def expand(base16, target=46):
    n = len(base16)
    rgbs = [hex_to_rgb(h) for h in base16]
    out = []
    extra = target - n
    per_pair = [extra // n] * n
    rem = extra % n
    for i in range(rem):
        per_pair[i] += 1

    for i in range(n):
        a = rgbs[i]
        b = rgbs[(i+1) % n]
        out.append(rgb_to_hex(a))
        steps = per_pair[i]
        for s in range(1, steps + 1):
            t = s / (steps + 1)
            out.append(rgb_to_hex(lerp(a, b, t)))
        if len(out) >= target:
            return out[:target]

    while len(out) < target:
        out.append(out[-1])
    return out[:target]

if __name__ == '__main__':
    infile = sys.argv[1]

    with open(infile) as f:
        j = yaml.safe_load(f)

    # --- FIXED: load base16 safely ---
    if 'colors' in j:
        base16 = j['colors']
    else:
        base16 = []
        for i in range(16):
            key = f"base{format(i, '02x')}"
            if key in j:
                base16.append(j[key])

    new = expand(base16)

    out = {
        'name': j.get('name', 'converted') + '-base46',
        'author': j.get('author', ''),
        'colors': new
    }

    outfile = infile.replace('.yaml', '') + '_base46.yaml'
    with open(outfile, 'w') as f:
        yaml.safe_dump(out, f, sort_keys=False)

    print("Wrote", outfile)
