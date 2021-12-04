# microbiome analysis tools

## [blast.sh](https://github.com/km4htc/microbiome-analysis/blob/14e198165d34a9e8c4c0fb7a3ce4a43ea86e48cb/blast.sh)
BLASTs a fasta file of queries and additionally retrieves complete taxonomic lineages outputting all to a csv. Requires blast command line tools and entrez direct e-utilities already installed. Only works for 16S rrna and ITS.  

options:  
-i path to input fasta (required)  
-o output path (optional)  
-n the number of hits per query desired (optional)  
example: blast.sh -i my.fa -o results.csv -n 10  

## [json2csv.py](https://github.com/km4htc/microbiome-analysis/blob/14e198165d34a9e8c4c0fb7a3ce4a43ea86e48cb/json2csv.py)  
Allows you to download the single json file from a batch upload to BLAST and flatten it into a human-readable csv. If there's specific data you want to retrieve for each hit, you're probably better off using the NCBI BLAST command line tools. This is more a convenience tool to use because the online gui is oftentimes faster than command line blastn -remote. Only handles 10 hits per query.  

options:  
-i path to json  
example: json2csv.py -i my.json  
