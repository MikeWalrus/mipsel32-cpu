#! /usr/bin/env python3

"""
On my machine, this takes around two DAYS to run.
"""

import subprocess
import multiprocessing as mp


def count_bit(n: int) -> int:
    ret = 0
    while n != 0:
        ret += n & 1
        n = n >> 1
    return ret


def gen_mlpoly_min_bits(width: int) -> int:
    p = subprocess.Popen(["mlpolygen", str(width)], stdout=subprocess.PIPE)
    min_bit_count = width + 2
    min_bit_count_mlpoly = None
    assert p.stdout is not None
    for line in p.stdout:
        mlpoly = int(line, 16)
        bit_count = count_bit(mlpoly)
        if bit_count < min_bit_count:
            min_bit_count_mlpoly = mlpoly
            min_bit_count = bit_count
    if min_bit_count_mlpoly is None:
        raise ValueError
    return min_bit_count_mlpoly


def main():
    with mp.Pool(8) as pool:
        mlpoly_list = [
            pool.apply_async(gen_mlpoly_min_bits, args=[i]) for i in range(33)
        ]
        mlpoly_list = [i.get() for i in mlpoly_list]

    mlpoly_list = [f"32'h{i:x}" for i in mlpoly_list]
    print(", ".join(mlpoly_list))


if __name__ == "__main__":
    main()
