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
         start_time = chron(times. = start_time),
         end_time = chron(times. = end_time))

# merge hire and rainfall data sets
hires_2019_clean <- hires_2019_clean %>% 
  inner_join(rain_2019, by = "start_date")

#--------------------------------------------------------------------

# work out elevation data
# make data set with relevant columns, need lat-long values and station id
# out put is a tibble
elevation_data <- hires_2019_clean %>% 
  distinct(end_station_longitude, end_station_latitude, end_station_id) %>% 
  select(end_station_longitude, end_station_latitude, end_station_id) %>% 
  mutate(station_id = end_station_id, .keep = "unused")

# convert tibble to data.frame
elevation <- as.data.frame(elevation_data) 

# run data.frame through `elevatr` which outputs a SpatialPointsDataFrame
# play around with `z` level to get the desired detail range is 5 - 14
aws_elev <- get_elev_point(elevation, prj = "EPSG:4326", z = 13, src = "aws")

# convert SPDF generated above into data.frame again
new_elevation <- as.data.frame(aws_elev) %>% 
  select(station_id, elevation) %>% 
  distinct(station_id, .keep_all = TRUE)

# joining the elevation data to main data set
hires_2019_clean <- hires_2019_clean %>% 
  inner_join(new_elevation, by = c("start_station_id" = "station_id")) %>% 
  inner_join(new_elevation, by = c("end_station_id" = "station_id"))

# rename elevation columns and create difference column based on difference between end and start elevations
hires_2019_clean <- hires_2019_clean %>% 
  mutate(start_elevation = elevation.x, end_elevation = elevation.y, .keep = "unused")

hires_2019_clean <- hires_2019_clean %>% 
  mutate(elevation_diff =  end_elevation - start_elevation)

# remove NAs
hires_2019_clean <- hires_2019_clean %>% 
  na.omit()

# write data to clean file
write_csv(hires_2019_clean, "clean_data/hires_2019_clean.csv")
