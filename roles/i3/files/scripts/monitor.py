#!/usr/bin/env python3
import os
import subprocess


def xrandr_listactivemonitors():
    # stream = os.popen('xrandr --listactivemonitors')
    return subprocess.Popen(['xrandr', '--listactivemonitors'], stdout=subprocess.PIPE, universal_newlines=True).communicate()[0]


def xrandr_query():
    return subprocess.Popen(['xrandr', '--query'], stdout=subprocess.PIPE, universal_newlines=True).communicate()[0]


def active_monitors():
    return xrandr_listactivemonitors()


if __name__ == "__main__":
    # print(xrandr_query())
    print(active_monitors())
