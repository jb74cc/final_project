# load in libraries

library(tidyverse)
library(janitor)
library(jsonlite)
library(here)
library(lubridate)
library(leaflet)
library(tsibbledata)
library(tsibble)
library(chron)
library(elevatr)
library(rgdal)

# read in data and EDA
jan_2019 <- fromJSON("raw_data/just_eat_data/2019/01.json", flatten=TRUE)
feb_2019 <- fromJSON("raw_data/just_eat_data/2019/02.json", flatten=TRUE)
mar_2019 <- fromJSON("raw_data/just_eat_data/2019/03.json", flatten=TRUE)
apr_2019 <- fromJSON("raw_data/just_eat_data/2019/04.json", flatten=TRUE)
may_2019 <- fromJSON("raw_data/just_eat_data/2019/05.json", flatten=TRUE)
jun_2019 <- fromJSON("raw_data/just_eat_data/2019/06.json", flatten=TRUE)
jul_2019 <- fromJSON("raw_data/just_eat_data/2019/07.json", flatten=TRUE)
aug_2019 <- fromJSON("raw_data/just_eat_data/2019/08.json", flatten=TRUE)
sep_2019 <- fromJSON("raw_data/just_eat_data/2019/09.json", flatten=TRUE)
oct_2019 <- fromJSON("raw_data/just_eat_data/2019/10.json", flatten=TRUE)
nov_2019 <- fromJSON("raw_data/just_eat_data/2019/11.json", flatten=TRUE)
dec_2019 <- fromJSON("raw_data/just_eat_data/2019/12.json", flatten=TRUE)

# bind all datasets together 
hires_2019 <- list(jan_2019, feb_2019, mar_2019, apr_2019, may_2019, 
                   jun_2019, jul_2019, aug_2019, sep_2019, oct_2019, 
                   nov_2019, dec_2019) %>%
  bind_rows()

# load in rainfall data
rain_2019 <- read_csv('raw_data/weather data for Edinburgh 2019/rainfall_2019.csv')

# clean data to leave date and rainfall columns
rain_2019 <- rain_2019 %>% 
  mutate(start_date = as.Date(
    with(rain_2019, 
         paste(year, mo, dy, sep = "-")), 
    "%Y-%m-%d")) %>% 
  select(start_date, rainfall_mm)

#--------------------------------------------------------------------

# clean data
# split date and time columns
# change duration column into minutes
# clean up time columns
hires_2019_clean <- hires_2019 %>% 
  separate(started_at, c("start_date", "start_time"), sep = " ") %>% 
  separate(ended_at, c("end_date", "end_time"), sep = " ") %>% 
  separate(start_time, "start_time", sep = "\\.") %>% 
  separate(end_time, "end_time", sep = "\\.") %>% 
  mutate(duration = round(duration / 60, 2),
         start_date = date(start_date),
         end_date = date(end_date),
         start_station_id = as.factor(start_station_id),
         end_station_id = as.factor(end_station_id),
         start_time = chron(times=start_time),
         end_time = chron(times=end_time))

# counting up the number of trips by station and adding to the main df
hires_2019_clean_tib <- hires_2019_clean %>% # make df into a tibble
  as_tibble(hires_2019_clean)

# get count of trips by station
# make new column of count
trips_df <- hires_2019_clean_tib %>% 
  group_by(start_station_id) %>% 
  count() %>% 
  mutate(number_of_trips = n)

# delete count column
trips_df <- trips_df %>% 
  select(!n) 

# join data frames together again
hires_2019_clean <- hires_2019_clean %>% 
  left_join(trips_df)

# merge hire and rainfall data sets
hires_2019_clean <- hires_2019_clean %>% 
  inner_join(rain_2019, by = "start_date")

#--------------------------------------------------------------------

# work out elevation data
# make data set with relevant columns, need lat-long values and station id
# out put is a tibble
elevation_data <- hires_2019_clean %>% 
  distinct(end_station_longitude, end_station_latitude, end_station_id) %>% 
  select(end_station_longitude, end_station_latitude, end_station_id)

# convert tibble to data.frame
elevation <- as.data.frame(elevation_data) 

# run data.frame through `elevatr` which outputs a SpatialPointsDataFrame
# play around with `z` level to get the desired detail range is 5 - 14
aws_elev <- get_elev_point(elevation, prj = "EPSG:4326", z = 12, src = "aws")

# convert SPDF generated above into data.frame again
new_elevation <- as.data.frame(aws_elev) %>% 
  select(end_station_id, elevation)

# joining the elevation data to main data set
hires_2019_clean <- hires_2019_clean %>% 
  full_join(new_elevation, by = "end_station_id")

# remove NAs
hires_2019_clean <- hires_2019_clean %>% 
  na.omit()

# write data to clean file
write_csv(hires_2019_clean, "clean_data/hires_2019_clean.csv")
