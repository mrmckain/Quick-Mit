#!/usr/bin/perl -w
use strict;


my %sequences;
my $sid;

my $seq_id;

open my $file, "<", $ARGV[0];
while(<$file>){
	chomp;
	if(/>/){
		$sid = substr($_,1);
		if($sid =~ /sc_/){
			$sid =~ /sc_(\d+)-(\d+)/;
			$seq_id = $sid;
		}
	}
	
	else{
		$sequences{$sid}.=$_;

	}
}

my $cox_pos;




my $cox_start;

open my $blast, "<", $ARGV[1];
while(<$blast>){
	chomp;
	my @tarray = split/\s+/;
		if($tarray[1] =~ /cox1/){

			if($tarray[9]-$tarray[8] > 0) {
				$cox_pos="+";
				$cox_start=$tarray[6]-1;

			}
			else{
				$cox_pos="-";
				$cox_start=$tarray[7]-1;
			}

		}
}

my $mtseq;
if($cox_pos eq "-"){
	my $tlen = length($sequences{$sid});
	my $half1 = substr($sequences{$sid},$cox_start);
	my $half2 = substr($sequences{$sid}, 0, $cox_start);
	$mtseq=$half2.$half1;
	$mtseq = reverse($mtseq);
	$mtseq =~ tr/ATGCatgc/TACGtacg/;
}
else{
	my $tlen = length($sequences{$sid});
	my $half1 = substr($sequences{$sid},0,$cox_start);
	my $half2 = substr($sequences{$sid}, $cox_start);
	$mtseq = $half2.$half1;
}


open my $fullout, ">", "$ARGV[2]\_FULLMT.fsa";
print $fullout ">$ARGV[2]\n$mtseq\n";

