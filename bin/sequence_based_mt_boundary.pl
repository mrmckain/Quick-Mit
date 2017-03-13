#!/usr/bin/perl -w
use strict;
my $sequence;
my $sid;
open my $file, "<", $ARGV[0];
while(<$file>){
	chomp;
	if(/>/){
		$sid = $_;
	}
	else{
		$sequence.=$_;
	}
}

my $seqlen = length($sequence);
my %regions;
my $current_start;
my $current_end;
my $ir;
my $count=0;

for (my $i=0; $i<$seqlen-151; $i++){
	my $tempseq = substr($sequence, $i, 151);
	my $check_seq = index($sequence, $tempseq, $i+1);
	if($check_seq > 0){
		if($ir){
			$current_end = $i;
		}
		else{
			if($current_end){
				$regions{$current_start}{$current_end}="sc";#. "_" . $current_start . "-" . $current_end;
				$count++;
				$current_start=$i;
				$current_end=$i;
				$ir=1;
			}
			else{
				$current_start=$i;
				$current_end=$i;
				$ir=1;
			}
		}
	}
	else{
	
		if($ir){
			$regions{$current_start}{$current_end+150}="ir";#"contig_" . $count. "_" . $current_start . "-" . $current_end;
				$count++;
				$current_start=$i+150;
				$current_end=$i;
				$ir=();
		}
		else{
			if($current_end){
				$current_end=$i;
			
			}
			else{
				$current_start=$i;
				$current_end=$i;
				$ir=();
			}
		}
	}
}
if($ir){
	$regions{$current_start}{$seqlen-1}="ir";
}
else{
	$regions{$current_start}{$seqlen-1}="sc";
}
for my $start (sort {$a<=>$b} keys %regions){
        for my $end (keys %{$regions{$start}}){
                if ($regions{$start}{$end} eq "ir"){
                        delete $regions{$start};
		
                }
	}
}
=item
my $ir_start=0;
for my $start (sort {$a<=>$b} keys %regions){
    for my $end (keys %{$regions{$start}}){
		if($regions{$start}{$end} eq "ir" && $ir_start ==0){
			$ir_start=1;
			next;
		}
		elsif($regions{$start}{$end} eq "ir" && $ir_start==1){
			delete $regions{$start}{$end};
			$ir_start=2;
		}
		elsif($regions{$start}{$end} eq "sc" && $ir_start==2){
			delete $regions{$start}{$end};
		}
	}
}
=cut

my %final_regions;
my $final_start;
my $final_end;
my $final_regionid;
for my $start (sort {$a<=>$b} keys %regions){
        for my $end (keys %{$regions{$start}}){
                if($final_start){
                        if($final_regionid ne $regions{$start}{$end}){
                                $final_regions{$final_start}{$final_end}=$final_regionid;
                                $final_start=$start;
                                $final_end = $end;
                                $final_regionid=$regions{$start}{$end};
                        }
                        else{
                                $final_end=$end;
                        }
                }
                else{
                        $final_start=$start;
                                $final_end = $end;
                                $final_regionid=$regions{$start}{$end};
                }
        }
}

$final_regions{$final_start}{$final_end}=$final_regionid;

open my $out, ">", $ARGV[1] . "_regions_split.fsa";
for my $start (sort {$a<=>$b} keys %final_regions){
        for my $end (keys %{$final_regions{$start}}){
               
                my $tempseq = substr($sequence,$start,($end-$start+1));
                my $tempid;
		if ($final_regions{$start}{$end} eq "ir"){
			$tempid = "ir_" . $start . "-" . $end;
		}
		else{
			$tempid = "sc_" . $start . "-" . $end;
		}
                print $out ">$tempid\n$tempseq\n";
        }
}
	
