#!/bin/bash

# script to create bam indexes for multiple .bam files

for i in *.bam

do

echo "Indexing: "$i        

samtools index $i $i".bai"

done