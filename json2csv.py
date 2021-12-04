#!/usr/bin/env python
import os
import argparse
import json
import pandas as pd
import numpy as np

# Parse command-line arguments
def options():
	parser = argparse.ArgumentParser(description="Get options for converting BLAST json to csv")
	parser.add_argument("-i", "--input", help="Input json file.", required=True)
	args = parser.parse_args()
	return args
    
def main():

	args = options()
	
	with open(args.input, 'r') as f:
		data = json.loads(f.read())  

	results = []
	n = len(pd.json_normalize(data['BlastOutput2']))
	i = 0
	while i < n:
		# get query/sample name
		j = pd.json_normalize(data['BlastOutput2'][i]['report']['results']['search'])
		q = j['query_title'][0]
	
		# get descriptive data
		d = pd.json_normalize(data['BlastOutput2'][i]['report']['results']['search']['hits'], ['description'], ['len'])
	
		# get score data
		scores = pd.json_normalize(data['BlastOutput2'][i]['report']['results']['search']['hits'], ['hsps'])

		# add query/sample label
		q = np.repeat(q, 10)
		d['query'] = q
		first = d.pop('query')
		d.insert(0, 'query', first)

		# combine descriptive and score data
		cat = [d, scores]
		d = pd.concat(cat, axis=1)
	
		# add to results
		results.append(d)
		i = i + 1
	
	r = pd.concat(results)
	r['query_coverage'] = r['len'] / (r['query_to'] - r['query_from'])
	r.to_csv('output.csv')

if __name__ == "__main__":
	main()