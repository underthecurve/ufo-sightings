import requests
from bs4 import BeautifulSoup
import csv
import os
import sys

reload(sys)
sys.setdefaultencoding('utf8')


f = csv.writer(open('ufo.csv', 'wb'))

f.writerow(["date", "city", "state", 'shape', "duration", "summary", "posted"])

states = ['AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY' ]

print len(states) # vector of 50 states + DC

for i in states:

    url = "http://www.nuforc.org/webreports/ndxl" + format(i) + ".html"
    r = requests.get(url)
    soup = BeautifulSoup(r.content, 'html.parser')

    for tr in soup.find_all('tr')[2:]:
        tds = tr.find_all('td')
        date = tds[0].text
        city = tds[1].text
        state = tds[2].text
        shape = tds[3].text
        duration = tds[4].text
        summary = tds[5].text
        posted = tds[6].text

        f.writerow([date, city, state, shape, duration, summary, posted])