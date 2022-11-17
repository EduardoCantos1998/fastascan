#! /bin/bash

# If directory is given as $1, find the fasta files and the links
if [[ -e $1 ]]; then 
    fafiles=$(find $1 -iregex '.*\.fa[a-zA-Z]*$')
else 
    # Find the files default settings
    fafiles=$(find . -iregex '.*\.fa[a-zA-Z]*$')
fi

# Check if there are fasta files
if [[ -z $fafiles ]]; then
    echo "There are no fasta files in this directory. Please try somewhere else." 
    exit
fi

# Print the headers into a file
echo -e "File name\t# of sequences\tSequence Length\tSymlink\tNuc/Prot" > table.FastaScan.tbl 

echo $fafiles | sed 's/\s/\n/g' | while read i; do

# Number of sequences
nums=$(grep --text '^>[a-zA-Z1-9]*' $i | wc -l) 

# Total length of each file
seq=$(sed -e '/^>.*/ d' -e 's/-//g' -e 's/\n//g' $i | tr '\0' '\n')
length=$(echo $seq | sed -e 's/\s//g' |  wc -m | awk '{print $1 - 1}') 
# Since there is only one line I can simply remove the last character which is
# the empty line.

# To make sure it doesn't count the characters of the file if no sequence is found
if [[ nums -eq 0 ]];then
    length=$(echo 0)
fi

# Check if the file is a link
if [[ -L $i ]]; then
    link=$(echo "True")
else
    link=$(echo "False")
fi

# Since every protein starts with a Methionine.
if [[ $(grep --text '^[Mm]' $i | wc -l) -gt 0 ]];then 
    nucprot=$(echo "Protein")
else
    nucprot=$(echo "Nucleotide")
fi

# Check if the length is 0, then the Nuc/Prot variable needs to be "NA"
if [[ $nums -eq 0 ]]; then
    nucprot=$(echo "Not Determined")
fi

# Put it all together
echo -e "$i\t$nums\t$length\t$link\t$nucprot" >> table.FastaScan.tbl

done

# Print the table with all the data
column -t -s $'\t' table.FastaScan.tbl

# Total number of sequences
echo 
echo "Total number of fasta files: " $(echo $fafiles | sed -e 's/\s/\n/g' | wc -l)
echo "Total number of sequences: " $(awk '(NR>1) && ($4!="True"){sum+=$2}END{print sum}' table.FastaScan.tbl)
echo "Total length of the sequences: " $(awk '(NR>1) && ($4!="True"){sum+=$3}END{print sum}' table.FastaScan.tbl)
echo 
echo "A random title: " 
echo $(cat $fafiles | grep --text '^>[a-zA-Z1-9]*' | shuf -n 1)

rm table.FastaScan.tbl
