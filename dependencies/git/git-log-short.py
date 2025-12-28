from sys import stdin
from itertools import cycle


def main():
    result: list[str] = []
    maxim: int = 0
    for line in stdin:
        split = line.split(' × ')
        for i in range(len(split)):
            result.append(split[i])
            maxim = len(split[i]) if not (i + 1) % 3 and len(split[i]) > maxim else maxim
        result.append('\n')
    for el, j in zip(result, cycle([0, 1, 2, 3, None])):
        if j is None:
            print()
            continue
        if not (j + 1) % 3:
            amount: int = maxim - len(el)
            spaces: str = amount * ' '
            print(f'{spaces}{el}', end=' ')
            continue
        print(el, end=' ')


if __name__ == '__main__':
    main()

