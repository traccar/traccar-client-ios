#!/usr/bin/python

import os
import optparse
import urllib2
import json
import base64
import re
import codecs
import xml.etree.ElementTree

parser = optparse.OptionParser()
parser.add_option('-u', '--user', dest='username', help='transifex user login')
parser.add_option('-p', '--password', dest='password', help='transifex user password')

(options, args) = parser.parse_args()

if not options.username or not options.password:
    parser.error('User name and password are required')

os.chdir(os.path.dirname(os.path.abspath(__file__)) + '/TraccarClient')

def request(url):
    req = urllib2.Request(url)
    auth = base64.encodestring("%s:%s" % (options.username, options.password)).replace("\n", "")
    req.add_header("Authorization", "Basic %s" % auth)
    return urllib2.urlopen(req)

mapping_en = {}

def load_en():
    data = request('https://www.transifex.com/api/2/project/traccar/resource/client/translation/en?file').read().decode('utf-8')
    for entry in xml.etree.ElementTree.fromstring(data).findall('string'):
        mapping_en[entry.attrib['name']] = entry.text.replace('Android', 'iOS')

load_en()

regex = re.compile(r'"([^"]+)" = "([^"]+)";')

def write_storyboard(code, mapping):
    in_file = codecs.open('en.lproj/MainStoryboard.strings', 'r', 'utf-8')
    out_file = codecs.open(code + '.lproj/MainStoryboard.strings', 'w', 'utf-8')
    for line in in_file:
        match = regex.match(line)
        if match:
            out_file.write('"' + match.group(1) + '" = "' + mapping.get(match.group(2), match.group(2)) + '";\n')
    out_file.close()
    in_file.close()

def write_strings(code, mapping):
    in_file = codecs.open('Base.lproj/Localizable.strings', 'r', 'utf-8')
    out_file = codecs.open(code + '.lproj/Localizable.strings', 'w', 'utf-8')
    for line in in_file:
        match = regex.match(line)
        if match:
            out_file.write('"' + match.group(1) + '" = "' + mapping.get(match.group(2), match.group(2)) + '";\n')
    out_file.close()
    in_file.close()

def write_settings(code, mapping):
    filename = 'InAppSettings.bundle/' + code + '.lproj/Root.strings'
    if not os.path.exists(os.path.dirname(filename)):
        os.makedirs(os.path.dirname(filename))
    in_file = codecs.open('InAppSettings.bundle/en.lproj/Root.strings', 'r', 'utf-8')
    out_file = codecs.open(filename, 'w', 'utf-8')
    for line in in_file:
        match = regex.match(line)
        if match:
            out_file.write('"' + match.group(1) + '" = "' + mapping.get(match.group(2), match.group(2)) + '";\n')
    out_file.close()
    in_file.close()

for directory in os.walk('.'):
    match = re.match(r"([a-z]{2}(?:-[A-Z]{2})?)\.lproj", directory[0][2:])
    if match:
        code = match.group(1)
        if code != 'en':
            mapping = {}
            data = request('https://www.transifex.com/api/2/project/traccar/resource/client/translation/' + code.replace('-', '_') + '?file').read()
            for entry in xml.etree.ElementTree.fromstring(data).findall('string'):
                mapping[mapping_en[entry.attrib['name']]] = entry.text
            write_storyboard(code, mapping)
            write_strings(code, mapping)
            write_settings(code, mapping)
            print code
