#!/usr/bin/env python
import csv
import random
import os.path

def addCSVRow(value, user, quote, csvfile):
	if (csvfile == 'votes.csv'):
		print "ADDING value: %d user %d quote: %d to votes" % (value, user, quote)
		with open('votes.csv', 'ab') as csvfile:
			writer=csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
			writer.writerow([value, user, quote])
	elif (csvfile == 'favorites.csv'):
		print "ADDING user %d quote: %d to favorites" % (user, quote)
		with open('favorites.csv', 'ab') as csvfile:
			writer=csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
			writer.writerow([user, quote])


#rake db:seed:dump MODELS=Vote APPEND=true
def generateCSV():
	vote_prob = [1] * 85 + [-1] * 15  #probability user upvotes high
	fave_prob = [1] * 85 + [0] * 15 #probability user favorites high

	if os.path.isfile('votes.csv'):
		os.remove('votes.csv')
	if os.path.isfile('favorites.csv'):
		os.remove('favorites.csv')

	
	random_user_ids= random.sample(range(1,1000), 500) #Sample 500 users
	#random_quote_ids= random.sample(range(1,3000), 100) #Random sample of 100 quotes

	for user_id in random_user_ids:
		for quote_id in random.sample(range(1000,1200), 10):
			vote_value = random.choice(vote_prob)
			addCSVRow(vote_value, user_id, quote_id, 'votes.csv')
			if(random.choice(fave_prob)): 	
				addCSVRow(0, user_id, quote_id, 'favorites.csv')

generateCSV()
