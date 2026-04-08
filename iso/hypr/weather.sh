
#!/usr/bin/env bash

# ВСТАВЬ СВОЙ КЛЮЧ ТУТ
API_KEY="ТВОЙ_API_КЛЮЧ"
CITY_ID="524901"
cache_file="/home/Michael/.config/hypr/weather_cache"

while true; do
  # Получаем и HTTP код, и тело ответа
  response=$(curl -s -w "\n%{http_code}" "https://api.openweathermap.org")
  
  # Разделяем тело и код
  body=$(echo "$response" | sed '$d')
  code=$(echo "$response" | tail -n1)

  if [ "$code" -eq 200 ]; then
    weather_info=$(echo "$body" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    temp = int(round(data['main']['temp']))
    hum = data['main']['humidity']
    desc = data['weather'][0]['description'].upper()
    sign = '+' if temp > 0 else ''
    print(f'{sign}{temp}°C {desc} | HUM: {hum}%')
except Exception as e:
    print('PARSING ERROR')
")
    echo "MOSCOW $weather_info" > "$cache_file"
  elif [ "$code" -eq 401 ]; then
    echo "MOSCOW AUTH ERROR (401) - WAIT FOR ACTIVATION" > "$cache_file"
  else
    echo "MOSCOW API ERROR ($code)" > "$cache_file"
  fi
  
  sleep 1800
done
