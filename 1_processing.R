library('tidyverse')

## run getdata.py in Python to get the ufo.csv data

###### UFO dataset #####
ufo <- read_csv('ufo.csv')

# create unique id for each event
ufo$id <- row.names(ufo)

# harmonize state abbreviations (50 states + DC)
length(unique((ufo$state)))
table(ufo$state)
ufo$state <- toupper(ufo$state)
table(ufo$state)

# clean up dates
ufo <- ufo %>% 
  separate(date, into = c('event.date', 'event.time'), sep = ' ') # 22 have no date, 1170 have no time

ufo$event.date <- as.Date(ufo$event.date, format = '%m/%d/%y')
ufo$event.year <- as.numeric(format(ufo$event.date, format="%Y"))
ufo$event.month <- format(ufo$event.date, format="%b")
ufo$event.day <- format(ufo$event.date, format="%d")

ufo$posted.date <- as.Date(ufo$posted, format = '%m/%d/%y')
ufo$posted.year <- as.numeric(format(ufo$posted.date, format="%Y"))
ufo$posted.month <- format(ufo$posted.date, format="%b")
ufo$posted.day <- format(ufo$posted.date, format="%d")

# fix early event dates (like 1968 miscoded as 2068)
# note: assuming 1900s but events dates on site (http://www.nuforc.org/webreports/ndxevent.html) indicate a small handful prior to the 1900s
ufo$event.year <- ifelse(ufo$event.year > 2018, ufo$event.year - 100, ufo$event.year) 
ufo$event.date <- as.Date(paste(ufo$event.year, ufo$event.day, ufo$event.month, sep = '-'), "%Y-%d-%b")

ufo$event.dow <- weekdays(ufo$event.date)

# order month names
ufo$event.month <- factor(ufo$event.month, levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"), ordered = T)

# extract notes by NUFORC staff & create hoax indicator variable
ufo$summary2 <- ufo$summary
ufo <- ufo %>% 
  separate(summary2, into = c('summary2', 'notes'), sep = 'NUFORC Note:')

ufo <- ufo %>% 
  separate(notes, into = c('notes', 'extra'), sep = 'PD')

ufo$hoax <- ifelse(grepl("hoax", ufo$summary, 
                         ignore.case=TRUE), 1, 0)
ufo <- ufo %>% select(-summary2, -extra)
ufo$has.note <- ifelse(ufo$hoax == 1 | is.na(ufo$notes) == F, 1, 0)

# save cleaned file
write_csv(ufo, 'ufo_clean.csv')

