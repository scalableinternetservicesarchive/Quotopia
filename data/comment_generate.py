#!/usr/bin/env python
import csv
import random
import string

def addCSVRow(comment, quote, user):
	print "ADDING value: %s quote %d user: %d" % (comment, quote, user)
	with open('comments.csv', 'ab') as csvfile:
		writer=csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
		try:
			writer.writerow([comment, quote, user])
		except UnicodeEncodeError as e:
			print e
			print "UnicodeEncodeError: continuing to next quote"

def randomComment(length):
	return ''.join(random.choice(string.lowercase) for i in range(length))

quote_id_list = random.sample(range(1,3000), 10)
comment_prob = ['yes'] * 60 + ['no'] * 40		# User comments with 60% chance

for user_id in xrange(1, 51):
	for quote_id in quote_id_list:
		comment_bool = random.choice(comment_prob)
		if comment_bool == 'no':
			continue
		length = random.randint(1,100)
		comment = randomComment(length)
		addCSVRow(comment, quote_id, user_id)