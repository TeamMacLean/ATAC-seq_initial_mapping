#!/bin/bash


refseq="/tsl/data/sequences/plants/arabidopsis/tair10/genome/TAIR10_genome.fa"

function indexreference(){

	echo "source bowtie2-2.3.5; bowtie2-build -f $1"
}

function alignment(){
	
	sbatch --mem 40G -J $5 -o log/${5}.log -n 2 --wrap " source bowtie2-2.3.5; source samtools-1.9;  bowtie2 -x $1 --no-discordant --no-mixed --fr --time --no-unal --qc-filter -1 $3 -2 $4 | samtools view -b --reference $2 --threads 8 | samtools sort -o $5"
}


for sampledir in /tsl/data/reads/jjones/dingp_ath_atacseq_2019_1/[gws]*; do
	
	# each directory is the sample folder
	sample=$(basename $sampledir)
	
	# lets get R1 filename
	for R1 in ${sampledir}/*/raw/*_R1.fastq.gz; do

		# get R2 filename
		R2=$(echo $R1 | sed 's/_R1.fastq/_R2.fastq/')
		basefilename=$(basename $R2 | sed 's/_R2.fastq.gz$//')
		sortedbam=$(echo ${sample}_${basefilename}_sorted.bam)
		
		# call alignment function
		alignment $refseq $refseq $R1 $R2 $sortedbam
		sleep 1
	done

done


