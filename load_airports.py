#!/usr/bin/env python3
import csv
import json
import io
import re
from urllib.request import urlopen

SOURCE_URL = "https://raw.githubusercontent.com/davidmegginson/ourairports-data/refs/heads/main/airports.csv"
NAME_FILTER = re.compile(r'(?:International|Intercontinental|National|Municipal|World|Airport.*)\s*')

with urlopen(SOURCE_URL) as response:
    f = io.TextIOWrapper(response, encoding='utf-8')
    reader = csv.DictReader(f)

    results = []
    for row in reader:
        # Filter out non-IATA airports and those without scheduled passenger service
        if (row['scheduled_service'] != 'yes' or
            row['iata_code'].strip() == '' or
            row['iso_country'] in ['CN', 'HK', 'MO', 'RU', 'BY', 'KP']):
            continue
        # Only retain large airports except a few
        if (row['type'] != 'large_airport' and
            row['type'] != 'medium_airport' and
            row['iso_country'] not in ['TW', 'JP', 'KR']):
                continue
        results.append({
                "id": row['iata_code'],
                "name": NAME_FILTER.sub('', row['name']).strip(),
                "latitude": round(float(row['latitude_deg']), 6),
                "longitude": round(float(row['longitude_deg']), 6),
                "country": row['iso_country'],
            })

# Sort
results.sort(key=(lambda i: i["country"] + i["id"]))

# Write to JSON
with open('airports.tmp.json', 'w+') as f:
    json.dump(results, f, indent=2, ensure_ascii=False)

print(f"Successfully processed {len(results)} entries to JSON.")
