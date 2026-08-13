from subprocess import run


def main(finish: int) -> None:
    value: int = int(
        run(["brightnessctl", "get"], text=True, capture_output=True, check=True).stdout
    )
    if value > finish:
        for i in range(value, finish - 1, -1):
            _ = run(["brightnessctl", "set", f"{i}"])
    if value < finish:
        for i in range(value, finish + 1):
            _ = run(["brightnessctl", "set", f"{i}"])


if __name__ == "__main__":
    print(main(int(input())))
