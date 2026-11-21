# Железо MagicBook

Проверено 21.11.2026. Это описание конкретной машины, а не требование к ISO.

| Компонент | Что стоит | Примечание |
|---|---|---|
| Модель | HUAWEI BOHK-WAX9X (MagicBook) | `product_name` |
| CPU | AMD Ryzen 5 3500U, 4 ядра / 8 потоков | Zen+, 3.7 ГГц boost |
| GPU | AMD Radeon Vega 8 (iGPU) | общая память, VRAM — узкое место |
| ОЗУ | 6.7 ГиБ доступно системе | остальное забирает iGPU и прошивка |
| Диск | KXG60ZNV256G TOSHIBA, 238.5 ГиБ | NVMe, `/dev/nvme0n1` |
| Экран | 1920×1080, eDP-1 | масштаб 1.0 |
| Wi-Fi | Realtek RTL8822CE (`10ec:c822`) | драйвер `rtw88_8822ce` |
| Bluetooth | Realtek (`1358:c123`) | `btusb` |
| Отпечаток | Goodix (`27c6:5110`) | `libfprint` + `goodixtls` |
| Камера | Quanta ov9734 (`0408:1040`) | `uvcvideo` |
| Клавиатура | keyd 2.6.0 | слои — `docs/keyd.md` |

Проверить самому:

```bash
cat /sys/devices/virtual/dmi/id/product_name
lscpu | rg 'Model name|Core|Thread'
free -h
lsblk -d -o NAME,SIZE,MODEL
cat /sys/class/net/wlp2s0/device/uevent | rg 'DRIVER|PCI_ID'
lsusb | rg -i 'goodix|realtek|quanta'
```

Особенности, которые влияют на конфиг:

- **VRAM:** Vega 8 делит память с CPU; при 6.7 ГиБ ОЗУ тяжёлые вкладки и
  игры упираются в память, а не в CPU. Отсюда отключённые эффекты и тени в
  `settings/decoration.lua`.
- **Wi-Fi:** `rtw88` не любит агрессивный powersave; если рвётся — смотреть
  `iw dev wlp2s0 get power_save`, а не менять NetworkManager наугад.
- **Отпечаток:** Goodix GF511, произвольное положение пальца не поддерживается
  аппаратно; нужен `buxel/libfprint` с патчем `goodixtls`.
- **Диск:** разметка в `host/hardware/disk.nix` и `identity.nix` привязана к
  `/dev/nvme0n1`; на другой машине это первое, что нужно менять.
