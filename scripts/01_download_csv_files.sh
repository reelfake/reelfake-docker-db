#!/bin/bash

csv_files=("actors.csv" "addresses.csv" "cities.csv" "countries.csv" "customers.csv" "genres.csv" "inventory.csv" "languages.csv" "movie_actors.csv" "movies.csv" "orders.csv" "rentals.csv" "staff.csv" "stores.csv")

for file_name in "${csv_files[@]}"; do
    download_url=$(curl -s -X GET "https://ipwnwstgwngs5b65wusv6jxsny0uaozi.lambda-url.ap-southeast-2.on.aws?file=$file_name" | jq -r '.url')
    curl -s -o "/docker-entrypoint-initdb.d/data/$file_name" "$download_url"
    echo "Download completed for $file_name..."
done