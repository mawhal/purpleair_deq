# load packages
library(httr)
library(jsonlite)


# set the API key and base URL
api_key <- "023A8F99-2BC6-11EE-A77F-42010A800009"
base_url <- "https://api.purpleair.com/v1/sensors"


# specify geolocation and search radius
latitude <- 37.33725
longitude <- -77.2689
radius <- 10  # Distance in miles from the specified coordinates

# specify fields to retrieve
fields <- c("name", "latitude", "longitude", "pm2.5", "temperature", "humidity")  # Data fields to retrieve


# modify the url to build the API request
url <- sprintf("%s?fields=%s&location_type=0&nwlat=%f&nwlng=%f&selat=%f&selng=%f&radius=%f&key=%s",
               base_url, paste(fields, collapse = ","), latitude, longitude, latitude, longitude, radius, api_key)


fields=paste0(“?average=0&start_timestamp=”, current.epoch, “&fields=latitude%2C%20longitude%2C%20altitude%2C%20rssi%2C%20humidity%2C%20temperature%2C%20pressure%2C%20pm2.5_atm%2C%20pm2.5_atm_a%2C%20pm2.5_atm_b%2C%20pm2.5_alt%2C%20pm2.5_alt_a%2C%20pm2.5_alt_b%2C%20pm2.5_cf_1%2C%20pm2.5_cf_1_a%2C%20pm2.5_cf_1_b%2C%20pm10.0_atm%2C%20pm10.0_atm_a%2C%20pm10.0_atm_b%2C%20pm10.0_cf_1%2C%20pm10.0_cf_1_a%2C%20pm10.0_cf_1_b”)


# send the API request and retrive data
response <- GET(url)
data <- content(response, "parsed")
