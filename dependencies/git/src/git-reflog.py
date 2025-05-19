from sys import stdin
from itertools import cycle


def main():
    obj = {
        0: float('inf'),
        1: float('inf'),
        2: 20,
        3: 50
    }
    lens = [0] * 4
    result = []
    for line in stdin:
        split = line.split()
        three = []
        perm = False
        for i in range(len(split)):
            if perm:
                result.append(' '.join(split[i:]))
                perm = False
                break
            if i >= 2:
                three.append(split[i])
                if split[i][-1] == ':':
                    result.append(' '.join(three))
                    perm = True
                if len(result[-1]) > lens[2]:
                    lens[2] = len(result[-1])
                continue
            if len(split[i]) > lens[i]:
                lens[i] = len(split[i])
            result.append(split[i])
        result.append('\n')
    for el, j in zip(result, cycle([0, 1, 2, 3, None])):
        if j is None:
            print()
            continue
        el = f'{el[:obj[j] - 1]}...' if len(el) > obj[j] else el
        print(el.rjust(lens[j]), end='   ')


if __name__ == '__main__':
    main()

