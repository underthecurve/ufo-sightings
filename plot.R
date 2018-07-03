library('tidyverse')
library('lubridate')
library('scales')

## run clean.R before this to get the ufo_clean.csv data

ufo <- read_csv('ufo_clean.csv')

# 1995-2017 is the most complete yearly time period
ufo.dates <- ufo %>% filter(is.na(event.date) == F & 
                              event.year >= 1995 & event.year != 2018 & hoax != 1) %>%
  group_by(event.day, event.month) %>%
  summarise(n = n())

ufo.dates$july4 <- ifelse((ufo.dates$event.day == '04' & ufo.dates$event.month == 'Jul'), 1, 0
)

# facetted plot
ggplot(ufo.dates, aes(x = as.numeric(event.day), y = n, fill = factor(july4))) +
  geom_bar(stat = 'identity') +
  facet_wrap(~event.month) +
  scale_x_continuous(labels = seq(1, 30, 5), breaks = seq(1, 30, 5)) +
  labs(x = 'day of month', y = 'number of reports') +
  theme(legend.position = 'none')

# let's try a different kind of data viz
## inspiration: https://www.washingtonpost.com/news/wonk/wp/2014/12/31/youre-gonna-get-soooo-wasted-tonight-and-google-knows-it/

ufo.dates$month.day <- paste(ufo.dates$event.month, as.numeric(ufo.dates$event.day))

# pad with a 'year' so R will recognize as a date: https://mgimond.github.io/ES218/Week02c.html
ufo.dates$date <- paste("2016", # note it's not really 2016 this is just a placeholder
                            ufo.dates$event.month, 
                            ufo.dates$event.day, sep="-")

# code January as the subsequent year so it will appear later in the plot
ufo.dates$date <- ifelse(ufo.dates$event.month == 'Jan', paste("2017", ufo.dates$event.month, 
                                                               ufo.dates$event.day, sep="-"), ufo.dates$date)

ufo.dates$date <- ymd(ufo.dates$date)

ufo.plot <- ggplot(ufo.dates, aes(x = date, y = n)) +
  scale_x_date(expand = c(0, 0), date_breaks = "month",
               date_minor_breaks = "day", 
               labels = c( # there's probably a better way to do this but oh well
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sept',
                          'Oct',
                          'Nov',
                          'Dec',
                          'Jan', '', ''))

ufo.plot.ribbon <- ufo.plot + geom_ribbon(aes(x = date, ymax = n), ymin = 0, fill = '#6497b1',  
                                                 color = '#005b96', size = 1,
                                                 alpha = .75)

ufo.plot.ribbon + labs(x = '', y = '', title = "Call Will Smith! UFO sightings peak on Independence Day",
                subtitle = "Cumulative daily reported UFO sightings, January 1995 through December 2017\n",
                caption = "Source: National UFO Reporting Center") + 
  scale_y_continuous(limits = c(0, 2000), 
                     expand = c(0, 0), 
                     labels = c('', "500", "1,000", "1,500", "2,000")) + 
  theme(axis.ticks = element_blank(), 
axis.line.x = element_line(color = '#005b96'), 
axis.text = element_text(size = 12)
) + theme(panel.grid.minor.x = element_blank(), 
          plot.title = element_text(size = 18, face = "bold"),
          plot.subtitle = element_text(size = 14), 
          plot.caption = element_text(hjust = -.01, color = 'grey30', size = 10)
          )
  
ggsave('plot.png', width = 8, height = 4.5)






