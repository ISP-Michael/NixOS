import subprocess


def revert() -> None:
    with open('./revert.txt', encoding='UTF-8') as file_out:
        value: str = file_out.read()
    if value:
        now: int = int(subprocess.run(
            ['brightnessctl', 'get'],
            capture_output=True,
            text=True,
            check=True
        ).stdout)
        for i in range(now + 1, int(value) + 1):
            _ = subprocess.run(['brightnessctl', 'set', f'{i}'])
        with open('./revert.txt', 'w', encoding='UTF-8') as file_in:
            _ = file_in.write('')


def main() -> None:
    if 'python' in subprocess.run(
        'ps aux | rg -i bnc.py',
        shell=True,
        capture_output=True,
        text=True,
    ).stdout:
        _ = subprocess.run(['pkill', '-f', 'python.*bnc.py'])
        revert()
        return
    revert()


if __name__ == '__main__':
    main()

