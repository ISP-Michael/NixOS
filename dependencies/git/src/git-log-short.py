from sys import stdin
from itertools import cycle


def main():
    lens:   list[int] = [0] * 4
    result: list      = []
    for line in stdin:
        split = line.split('⊖')
        for i in range(len(split)):
            if i == 2:
                split[i] = f'{split[i][:17]}...' if len(split[i]) > 20 else split[i]
            if i == 3:
                add = ' '.join(split[i:])
                result.append(add if len(add) <= 50 else f'{add[:47]}...')
                break
            if len(split[i]) > lens[i]:
                lens[i] = len(split[i])
            result.append(split[i])
        result.append('\n')
    for el, j in zip(result, cycle([0, 1, 2, 3, None])):
        if j is None:
            print()
            continue
        print(el.ljust(lens[j]), end='   ')


if __name__ == '__main__':
    main()

