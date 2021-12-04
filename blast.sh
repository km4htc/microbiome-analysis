#!/bin/sh

# REQUIRED DEPENDENCIES
#install blast command line tools
#	https://www.ncbi.nlm.nih.gov/books/NBK279690/
#install entrez utilities
#	https://www.ncbi.nlm.nih.gov/books/NBK179288/

while getopts "i:o:n:" flag
do
	case $flag in
		i) i=$OPTARG ;; # input fasta
		o) o=$OPTARG ;; # output path
		n) n=$OPTARG ;; # number of hits wanted per query
	esac
done

# Make sure input is specified
if [ -z "${i}" ];
then
	echo "Input fasta file is required with -i";
	exit;
fi

# Check if outpath is specified, otherwise default to 'taxtable.csv'
if [ -z "${o}" ];
then
	o = 'taxtable.csv' ;
fi

# Check if number hits is specified, otherwise default to 10
if [ -z "${n}" ];
then
	n = 10 ;
fi
	
# BLAST input fasta
# Megablast against the 16S rrna database
# options set to online default
blastn -db rRNA_typestrains/prokaryotic_16S_ribosomal_RNA \
	-query $i \
	-evalue 0.05 \
	-word_size 28 \
	-outfmt "10 delim=, sacc bitscore score pident mismatch qcovs qstart qend sstart send" \
	-max_target_seqs $n \
	-out blast_scores \
	-remote ;

# retrieve and format taxonomy
awk -F , '{print $1}' blast_scores > accessions ;
while read acc
do 
	tax=$(esearch -db nuccore -query $acc < /dev/null | elink -target taxonomy | efetch -format native -mode xml | grep "<Lineage>") ;
	echo $acc","$tax ;
done < accessions >> taxonomy
sed -i '' 's/ <Lineage>//g' taxonomy ;
sed -i '' 's:</Lineage>::g' taxonomy ;
sed -i '' 's/; /,/g' taxonomy ;
#sed -i '' 's/    //g' taxonomy ;

# ensure blast results and taxonomy are sorted the same
sort -o blast_scores{,} ;
sort -o taxonomy{,} ;

# create a header and combine blast results with taxonomy
echo -e "sacc,bitscore,score,pident,mismatch,qcovs,qstart,qend,sstart,send,ncbi_class,kingdom,phylum,class,order,family,genus\n$(join -j 1 -t , blast_scores taxonomy)" > $o ;

# cleanup
rm blast_scores ;
rm taxonomy ;
rm accessions ;
