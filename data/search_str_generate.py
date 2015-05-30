#!/usr/bin/env python
import csv
import random
import os.path
import operator
import itertools
import collections
from operator import itemgetter
import re

def addCSVRow(search_str):
	print ("ADDING search_str: " + search_str)
	with open('search_str.csv', 'ab') as csvfile:
		writer=csv.writer(csvfile, delimiter=",", quotechar='|', quoting=csv.QUOTE_MINIMAL)
		try:
			writer.writerow([search_str])
		except UnicodeEncodeError as e:
			print e
			print "UnicodeEncodeError: continuing to next quote"

def generateCSV():
	quotes = open('4000_quotes.csv')
	
	if os.path.isfile('search_str.csv'):
		os.remove('search_str.csv')

	# putting the words into a dictionary with the # of occurrences
	counts = dict()
	for line in quotes:
		line = re.sub('[|,;.""()!:?-]', ' ', line)
		words = line.split(' ')
		for word in words:
			if (not word.isdigit()) and (len(word) >= 5):
				if word not in counts:
					counts[word] = 1
				else:
					counts[word] += 1		
	
	# sorting the list of words by the number of occurrences
	sorted_counts = sorted(counts.items(), key=lambda x:x[1], reverse=True)
	#sorted_counts = collections.OrderedDict(sorted(counts.items(), key=operator.itemgetter(1)))				

	for word in sorted_counts[:1000]:
		#print word[0], word[1]
		addCSVRow(word[0])

generateCSV()
