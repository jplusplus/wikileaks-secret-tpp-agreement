#!/usr/bin/env python
# Encoding: utf-8
# -----------------------------------------------------------------------------
# Project : 
# -----------------------------------------------------------------------------
# Author : Edouard Richard                                  <edou4rd@gmail.com>
# -----------------------------------------------------------------------------
# License : proprietary journalism++
# -----------------------------------------------------------------------------
# Creation : date
# Last mod : date
# -----------------------------------------------------------------------------

import csv, os, json

with open(os.path.join(os.path.dirname(__file__), "data.csv")) as cpi_file:
	spamreader = csv.reader(cpi_file, delimiter=',', quotechar='"')
	results = {}
	header = spamreader.next()[1:]
	for row in spamreader:
		country = row[0]
		results[country] = {}
		total_line = sum([int(v) for v in row[1:] if v != ""])
		for i, other_country in enumerate(header):
			if country != other_country:
				occ  = int(row[i+1])
				prop = float(occ/float(total_line))
				results[country][other_country] = {"occ":occ, "prop":prop}
	print json.dumps(results)
