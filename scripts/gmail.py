#! /usr/bin/env python

import urllib.request
from xml.etree import ElementTree as etree

# Enter your username and password below within quotes below, in place of ****.
# Set up authentication for gmail
auth_handler = urllib.request.HTTPBasicAuthHandler()
auth_handler.add_password(realm='mail.google.com',
                          uri='https://mail.google.com/',
                          user= 'gidalte@gmail.com',
                          passwd= 'a4b3c6d10')
opener = urllib.request.build_opener(auth_handler)
# ...and install it globally so it can be used with urlopen.
urllib.request.install_opener(opener)

gmail = 'https://mail.google.com/gmail/feed/atom'
NS = '{http://purl.org/atom/ns#}'
with urllib.request.urlopen(gmail) as source:
    tree = etree.parse(source)
fullcount = tree.find(NS + 'fullcount').text

print(fullcount + ' new')
