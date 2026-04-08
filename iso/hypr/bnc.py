import subprocess as sp


def notify_send() -> None:
    _ = sp.run(['notify-send', 'Locking soon...'])


def main() -> None:
    start = sp.run(
        ['brightnessctl', 'get'],
        capture_output=True,
        text=True,
        check=True
    ).stdout.strip()
    if int(start) <= 10:
        notify_send()
        return
    with open('./revert.txt', 'w', encoding='UTF-8') as file_in:
        _ = file_in.write(start)
    notify_send()
    _ = sp.run(['sleep', '1'])
    for i in range(int(start) - 1, 9, -1):
        _ = sp.run(['brightnessctl', 'set', f'{i}'])


if __name__ == '__main__':
    main()

