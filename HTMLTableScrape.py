#!/usr/bin/python
import os, csv
import urllib.request as rq
import lxml.etree as et


# SET CURRENT DIRECTORY
cd = os.path.dirname(os.path.abspath(__file__))

# READ HTML DATA
bartlebyweb = rq.urlopen("http://www.bartleby.com/titles/")
bartlebypage = bartlebyweb.read()

html = et.HTML(bartlebypage)

table = html.xpath('//table[7]/tr')

# EXTRACT WEB DATA INTO LISTS
titles = [];
authors = []
for i in range(len(table)):
    data = html.xpath('//table[7]/tr[{0}]/td/a[1]/text()'.format(i))
    if len(data) == 0:
        titles.append("")
    else:
        titles.append(data[0].replace("\x92", "'").replace("\x96", ""))

    data = html.xpath('//table[7]/tr[{0}]/td/a[2]/text()'.format(i))        
    if len(data) == 0:
        authors.append("")
    else:
        authors.append(data[0].replace("\x92", "'").replace("\x96", ""))


# OUTPUT LISTS TO CSV
with open(os.path.join(cd,'HTMLDATA_py.csv'), 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['Title', 'Author'])
    
    for t,a in zip(titles, authors):
        if len(t) > 0:
            writer.writerow([t, a])
f.close()

print("Successfully exported HTML data to CSV!")

