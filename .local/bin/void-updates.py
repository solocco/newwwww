#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import json

ACTIONS = {"update", "install", "configure", "reinstall"}


def get_update_count():
    try:
        out = subprocess.check_output(
            ["xbps-install", "-un"],
            text=True,
            stderr=subprocess.DEVNULL,
        )
    except FileNotFoundError:
        return None
    except subprocess.CalledProcessError as e:
        out = e.output or ""

    count = 0
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 2 and parts[1] in ACTIONS:
            count += 1
    return count


updates = get_update_count()

if updates is None:
    data = {
        "class": "error",
        "percentage": 0,
        "tooltip": "xbps-install not found",
    }
else:
    data = {
        "class": "has-updates" if updates > 0 else "up-to-date",
        "percentage": updates,
        "tooltip": f"{updates} package(s) can be updated" if updates > 0 else "System up to date",
    }

print(json.dumps(data))
