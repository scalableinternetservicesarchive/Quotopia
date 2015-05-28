#!/usr/bin/env python
import csv
import random

def addCSVRow(value, user, quote):
	print "ADDING value: %d user %d quote: %d" % (value, user, quote)
	with open('votes.csv', 'ab') as csvfile:
		writer=csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
		try:
			writer.writerow([value, user, quote])
		except UnicodeEncodeError as e:
			print e
			print "UnicodeEncodeError: continuing to next quote"

quote_id_list = random.sample(range(1,3000), 5)
print quote_id_list

for user_id in xrange(1, 51):
	for quote_id in quote_id_list:
		value = random.choice([1, -1])
		addCSVRow(value, user_id, quote_id)
