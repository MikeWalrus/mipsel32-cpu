#! /usr/bin/env python3

import sys


def new_freq(old_freq: float, wns: float) -> float:
    old_cycle = 1 / (old_freq * (10**6))
    new_cycle = old_cycle - wns * (10**-9)
    new_freq = 1 / (new_cycle) / (10**6)
    return new_freq


def main():
    print(new_freq(float(sys.argv[1]), float(sys.argv[2])))


if __name__ == "__main__":
    main()
