#!/usr/bin/env python3
import time
import psutil
import sys
import os


def get_temperature():
    try:
        temps = psutil.sensors_temperatures()
        if 'coretemp' in temps:
            return temps['coretemp'][0].current
        elif 'k10temp' in temps:
            return temps['k10temp'][0].current
    except:
        pass
    try:
        with open('/sys/class/thermal/thermal_zone0/temp', 'r') as f:
            temp = int(f.read().strip()) / 1000.0
            return temp
    except:
        pass
    try:
        import subprocess
        result = subprocess.run(['acpi', '-t'], capture_output=True, text=True)
        if result.returncode == 0:
            temp_line = result.stdout.split('\n')[0]
            return float(temp_line.split(' ')[3].replace('C', ''))
    except:
        pass
    return 0


def main():
    prev_net_io = None
    internet_checked = 0
    while True:
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        mem_percent = memory.percent
        mem_used_gb = memory.used / (1024**3)
        mem_total_gb = memory.total / (1024**3)
        disk = psutil.disk_usage('/')
        disk_percent = disk.percent
        temp = get_temperature()
        net_io = psutil.net_io_counters()
        net_status = 0
        if internet_checked == 0:
            try:
                import subprocess
                result = subprocess.run(['ping', '-c', '1', '-W', '1', '8.8.8.8'], 
                                      capture_output=True, text=True)
                net_status = 1 if result.returncode == 0 else 0
            except:
                net_status = 0
            internet_checked = 10
        else:
            internet_checked -= 1
        download_speed = 0
        upload_speed = 0
        if prev_net_io is not None:
            download_speed = (net_io.bytes_recv - prev_net_io.bytes_recv) / 1024
            upload_speed = (net_io.bytes_sent - prev_net_io.bytes_sent) / 1024
        prev_net_io = net_io
        print(f'{cpu_percent:.1f}|{mem_percent:.1f}|{mem_used_gb:.1f}|{mem_total_gb:.1f}|{disk_percent}|{temp:.1f}|{net_status}|{download_speed:.1f}|{upload_speed:.1f}')
        _ = sys.stdout.flush()


if __name__ == '__main__':
    main()
