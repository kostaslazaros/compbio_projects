#/usr/bin/perl/

use warnings;
use strict;

# Read DNA sequence from file
sub read_fasta {
    my ($input_file) = @_;
    open my $input_handler, '<', $input_file or die "Can't open $input_file: $!";
    my $sequence = '';
    while (my $line = <$input_handler>) {
        chomp $line;
        if ($line =~ /^>/) {
            next;
        }
        else {
            $sequence .= $line;
        }
    }
    close $input_handler;
    return $sequence;
}

# Create reverse compliment strand
sub reverse_complement {
    my ($sequence) = @_;
    my $reverse_complement = reverse $sequence;
    $reverse_complement =~ tr/ACGTacgt/TGCAtgca/;
    return $reverse_complement;
}


sub locate_genes {
    my ($sequence, $regex, $symbol) = @_;
    my @results = ();
    my $seq_len = length($sequence);
    my $orf_counter = 0;
    while ($sequence =~ /$regex/g) {
        $orf_counter +=  1;
        my $start_pos = pos($sequence) - length($&);
        my $start_searching_index = pos($sequence);
        for (my $pos = $start_searching_index; $pos < length($sequence);$pos+=3) {
            my $codon = substr($sequence, $pos, 3);
            if ($codon eq "TAA" | $codon eq "TAG" | $codon eq "TGA") {			
                    my $ORF_end = $pos + 3;
                    my $gene_size = $ORF_end - $start_pos;
                    my $gene = substr($sequence, $start_pos, $gene_size);
                    my $true_start_pos = $start_pos + 1;
                    my $true_reverse_start = $seq_len - $start_pos;
                    my $true_reverse_end = $seq_len - $ORF_end + 1;
                    if ($symbol eq "+") {

                        push @results, ("|+|${true_start_pos}|${ORF_end}|${gene_size}\n${gene}");
                    }
                    else {
                        push @results, ("|-|${true_reverse_start}|${true_reverse_end}|${gene_size}\n${gene}");                        
                    }
                last;
            }
	    }
    }
    return @results;
}


# Driver function that also prints results to file
sub main {
    my ($input_fasta, $output_fasta) = @_;
    my $sequence = read_fasta($input_fasta);
    my $reverse_complement = reverse_complement($sequence);
    my @res_plus = locate_genes($sequence, '[TA][AC]AGGA[GA][GA][ATGC]{4,10}ATG', "+");
    my @res_minus = locate_genes($reverse_complement, '[TA][AC]AGGA[GA][GA][ATGC]{4,10}ATG', "-");
    my $counter = 0;
    open my $output_handler, '>', $output_fasta or die "Can't open $output_fasta: $!";
    foreach my $res (@res_plus) {
        $counter +=1;
        print $output_handler ">", $counter, $res, "\n";
    }
    foreach my $res (@res_minus) {
        $counter +=1;
        print $output_handler ">", $counter, $res, "\n";
    }
    close $output_handler;
}


main("yersinia_genome.fasta", "yersinia_genes.fasta");
