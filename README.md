![](www/title.png?raw=true "Pres")

# <span style="color: #F27F1B;">Just Eat Cycle Hire Scheme</span>

CodeClan Professional Data Analysis Course - final project.

Just Eat Cycles was a bike hire scheme that ran in Edinburgh from 2018 to 2021. The scheme was operated by a company called Serco with Just Eat coming onboard as the sponsor. There was a fleet of 500 pedal bikes and 150 eBikes deployed to stations across Edinburgh. Customers had the option of paying per ride, per day or taking out an annual subscription to use the service. The scheme although popular came to an end in September 2021 with Serco citing issues such as vandalism of bikes and stations as part of the reason not to continue. Edinburgh Council are still trying to work out a way to bring the scheme back to the streets.

I thought I would look at the scheme's usage across 2019 the first full year of operation and also before the pandemic hit. I wanted to see how popular the scheme was and what were any key points that could be used to help determine future iterations of the scheme.

Slides of my final presentation can be found in the `slide_presentation` folder.

![](www/1.png?raw=true "Pres")
![](www/2.png?raw=true "Pres")
![](www/3.png?raw=true "Pres")
![](www/4.png?raw=true "Pres")

## <span style="color: #F27F1B;">Context</span>


My analysis shows how popular the scheme was in 2019, with just shy of 125k journeys being made. I looked in to how the rain affects the number of hires, it did have an effect but perhaps not as much as you would imagine. I also looked at time of day analysis to establish when the bikes were being used. This can be good for the business to make sure they have the maximum number of bikes available at peak times. It also shows the business the broad use of the scheme throughout the day. Look at hires by day of the week was also interesting as it shows the demand is pretty constant throughout the week. Analysing the location of stations shows which are the most popular start points in the city as well as the busiest end points. This can be really helpful to the business as it allows the stocking of popular stations at busy times and can also show where the majority of bike could end up at the end of the day.


## <span style="color: #F27F1B;">Data</span>

The data used in this analysis came from the hire scheme detailing hires from 2019. It is open data and has obviously been pared back from the actual data gathered as it only contains trip dates, start and end points, station ids and names and trip durations. No personal information was contained in the data. For a deeper analysis it would be nice to have some more in depth data such as gender and age splits of the people using the service along with subscription vs single ride info, perhaps also route info for each journey to see what routes if any were especially popular.

To add some extra dimensions I downloaded weather data for the period to see if it had any impact on hires. I also managed to get the elevation details for each bike hire station using their longitude and latitude coordinates, pulling the info from aws terrain servers.

#### Types of data

Once I had all my data cleaned and compiled together I was dealing with a mixture of date/time variables for the start and end dates and times. There were also character variables for station names and descriptions. Numeric variables made up the balance of the rest of the columns for things like lat/long coordinates, journey durations, station elevations etc. I converted the station ids to factors.

#### Data formats

The data was supplied in .json format with a separate file for each month in 2019. Weather data was downloaded from the web in .csv format and the elevation data was scraped from aws as a Spatial Points Data Frame which I then converted to a regular data frame to incorporate with the rest of the data.

#### Data quality and bias

The data contained only trip information with no personal info included so although a little thin, did not in my opinion contain any bias.

## <span style="color: #F27F1B;">Ethics</span>

I don't have any ethical concerns with the capture or use of this data as there is no way of identifying an individual from the data, and the data was supplied by the organisation involved.

## <span style="color: #F27F1B;">Analysis</span>

#### Stages in the data analysis process

The main stages in my data analysis process were initially to bind the 12 monthly data sets together to make one year long set. I then had to split the `started at` variable into `start date` and `start time`, the same for `ended at`. The `duration` variable was in seconds so I mutated it in to minutes and rounded to 2 decimal points. The start and end dates and times all needed to be converted to date/time variables as they were still character variables.

Next I joined in the rainfall data that I had sourced from `power.larc.nasa.gov/data-access-viewer/`. I joined the data on `start date` to join the days rainfall in the correct places.

Finally I joined in the elevation data for the various stations that I had pulled from `aws` at `registry.opendata.aws/terrain-tiles/`.

#### Tools for data analysis

The main tools I used for my analysis were `R Studio` for the importing, cleaning and analysing of the data. I used Chrome to look for and access the other data to merege with the original data set. I used `Affinity Designer` for some of the work for the presentation and `Keynote` to put together the slides.

#### Descriptive, diagnostic, predictive and prescriptive analysis

**Descriptive Analytics** were used to understand bike hires from 2019. I analysed use by time of day, duration, location. I also looked at the relationship between some stations, if journeys were A to B or round trips etc.

I used **Diagnostic Analytics** in the form of a Hypothesis Test to determine if weather, specifically rainfall, had an effect of bike hires.

## <span style="color: #F27F1B;">In conclusion</span>

- I think that the scheme was well used
- Use is spread thought the day and into the night, late afternoon looks to be popular
- Hires peak in the summer, especially August, perhaps due to the festival
- Rain does affect hires but not by that much in 2019
- Future schemes could look to make more of round trips, perhaps creating a companion app to highlight sights or tours that could be made from specific stations. It could be particularly helpful for tourists or visitors to the city
- More eBikes for hilly routes, or first thing in morning at low elevation stations
