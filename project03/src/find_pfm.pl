#!/usr/bin/perl
use warnings;
use strict;

my $seqs=$ARGV[0]; 
my %PFM;
my $base;
my $length;
my $consensus = "";
my $consensus_tabbed = "";
my $score = 0;

open(INPUT,"<",$seqs) or die "$!\n";
open(OUTPUT,">","pfm.txt") or die "$!\n";

# Check if the sequences contain valid letters.
while(my $line=<INPUT>){ 
	chomp $line; 
	if($line!~/^[ATCG]+$/)
	{ 	
		print "No valid letters in $seqs \n";
		exit;
	}
}
close(INPUT);

# Calculate each nucleotide's frequency in each position
open(INPUT,"<",$seqs) or die "$!\n";
while(my $line=<INPUT>){ 
	chomp $line;
	$length=length($line);
	for (my $i=0;$i<length($line);$i++)
	{ 	
		$base=substr($line,$i,1);
		$PFM{$base}{$i+1}++;
	}
}

# Print the Position Frequency Matrix
foreach $base (keys %PFM){
	print OUTPUT "$base\t";
	for (my $i=1;$i<=$length;$i++)
	{
		if(!defined($PFM{$base}{$i}))
		{
			 $PFM{$base}{$i} = 0;
		}
		print OUTPUT "$PFM{$base}{$i}\t";
	}
	print OUTPUT "\n";
}

# Find the consensus dna sequence and 
# if two or more nucleotides have the same frequency
# then print them both with the "|" symbol between them

for (my $i = 1; $i <= $length; $i++){
	my $max = 0;
	my $max_base = "";
	foreach $base (keys %PFM){
		if($PFM{$base}{$i} > $max){
			$max = $PFM{$base}{$i};
			$max_base = $base;
		}
		elsif($PFM{$base}{$i} == $max){
			$max_base = $max_base."|".$base;
		}
	}
	$consensus_tabbed = $consensus_tabbed.$max_base;
}

# Find the consensus dna sequence and calculate the score and print to output file
for (my $i = 1; $i <= $length; $i++){
	my $max = 0;
	my $max_base = "";
	foreach my $base(keys %PFM){
		if($PFM{$base}{$i} > $max){
			$max = $PFM{$base}{$i};
			$max_base = $base;
		}
	}
	$consensus = $consensus.$max_base;
	$score += $max;
}


# Print needed output to output file
print OUTPUT "$consensus\n";
print OUTPUT "$consensus_tabbed\n";
print OUTPUT "Score= $score\n";


# Close input and output files
close(INPUT);
close(OUTPUT);
