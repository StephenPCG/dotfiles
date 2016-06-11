#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import shutil

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))

def symlink(src, dst):
    if os.path.islink(dst) and os.readlink(dst) == src:
        print "already symlinked"
    elif not os.path.exists(dst):
        os.symlink(src, dst)
        print "symlinked"
    else:
        print "target file already exist, NOT updated"

def copy(src, dst):
    if not os.path.exists(dst):
        shutil.copyfile(src, dst)
        print "copied"
    else:
        print "file already exist, NOT updated, showing diff:"
        os.system("diff -u %s %s" % (src, dst))

def main():
    with open(os.path.join(SCRIPT_PATH, "links.txt")) as fp:
        for line in fp.readlines():
            line = line.split("#", 1)[0].strip()
            if not line:
                continue
            frags = line.split()
            src, dst = frags[0], frags[1]

            src_path = os.path.join(SCRIPT_PATH, src)
            if dst.startswith("/"):
                dst_path = dst
            else:
                dst_path = os.path.join(os.path.expanduser("~"), dst)

            install = symlink
            for arg in frags[2:]:
                if arg == "linuxonly" and os.uname()[0] != "Linux":
                    install = None
                elif arg == "copy":
                    install = copy

            print "Installing %s -> %s:" % (src, dst),
            if install is not None:
                install(src_path, dst_path)
            else:
                print "not for current platform, ignored"

if __name__ == "__main__":
    main()
