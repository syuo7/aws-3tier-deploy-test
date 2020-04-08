# Script for ELB request and response verification

from bs4 import BeautifulSoup as bs
from urllib.request import urlopen
f = open('response.txt', 'w')
for s in range(0, 50): # set the number of request range
    try:
        data = urlopen('set your EIP dns address here').read() # set the EIP address
    except:
        print("Elb address is wrong")
    soup = bs(data, 'html.parser')
    f.write("Request %d: \n" % (s+1))
    for span in soup.findAll('p', class_="smaller")[5]:
        f.write(span.string)
    f.write(", ")
    for span in soup.findAll('p')[1]:
        f.write(span.string)
    f.write("\n\n")
f.close()

