#/usr/bin/perl/

use warnings;
use strict;

# Function for part B1
sub parse_bed_file{
    my ($input_file) = @_;
    my $eid = "";
    my @bed_array;
    open(my $input_handler, "<", $input_file) or die "$!\n";
    while (my $line = <$input_handler>){
        chomp $line;
        my @bed_cols = split("\t", $line);
        if ($bed_cols[3] ne $eid){
            $eid = $bed_cols[3];
            push @bed_array, \@bed_cols;
        }
    }
    close $input_handler;
    return \@bed_array;
}

# Function for part B2
sub hash_bed_file{
    my ($input_file, $output_file) = @_;
    my %bed_hash;
    open(my $input_handler, "<", $input_file) or die "$!\n";
    while (my $line = <$input_handler>){
        chomp $line;
        my @bed_cols = split("\t", $line);
        my $length = $bed_cols[2] - $bed_cols[1];
        my @eids = split("@",$bed_cols[3]);
        my $eid = $eids[1];
        if (exists $bed_hash{$eid}){
            $bed_hash{$eid} = $bed_hash{$eid} + $length;
        }
        else{
            $bed_hash{$eid} = $length;
        }
    }
    close $input_handler;
    open(my $output_handler, ">", $output_file) or die "$!\n";
    foreach my $key (keys %bed_hash){
        my $value = $bed_hash{$key};
        print $output_handler "$key\t$value\n";
    }
    close $output_handler;
}

# Write to file
sub write_bed{
    my ($output_file, @bed_array) = @_;
    open my $output_handler, '>', $output_file or die "Can't open $output_file: $!";
    foreach my $bed_line (@bed_array) {
        print $output_handler join("\t", @$bed_line), "\n";
    }
    close $output_handler;
}



sub first_exons{
    my ($input_file, $output_file) = @_;
    my $bed_array_ref = parse_bed_file($input_file);
    write_bed($output_file, @$bed_array_ref);
}


first_exons('human_exons_prCoding_exercise_set.bed', 'first_exons_coordinates.bed');
hash_bed_file('human_exons_prCoding_exercise_set.bed', 'exonic_length_per_transcript.txt');