#!/usr/bin/env python
import csv
import random
import os.path

def addCSVRow(value, user, quote):
	print "ADDING value: %d user %d quote: %d" % (value, user, quote)
	with open('votes.csv', 'ab') as csvfile:
		writer=csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
		try:
			writer.writerow([value, user, quote])
		except UnicodeEncodeError as e:
			print e
			print "UnicodeEncodeError: continuing to next quote"

def generateCSV():
	quote_id_list = random.sample(range(1,3000), 5)
	vote_prob = [1] * 80 + [-1] * 20			# User upvotes with 80% chance

	if os.path.isfile('votes.csv'):
		os.remove('votes.csv')

	for user_id in xrange(1, 51):
		for quote_id in quote_id_list:
			value = random.choice(vote_prob)
			addCSVRow(value, user_id, quote_id)

generateCSV()
