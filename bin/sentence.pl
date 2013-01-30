# 1箇所だけ全角を使っている
use strict;
use warnings;
use Data::Dumper;

use Pod::L10N::Model;

use utf8;

binmode(STDOUT, ':encoding(euc-jp)');

{
    my %cv;
    my $encoding = '';
    my $meta = '';

    my $base;
    {
	open my $f1, '<:encoding(euc-jp)', $ARGV[0] or die "$ARGV[0]: $!";
	my @slurp = (<$f1>);
	close $f1;
	my $sl = join '', @slurp;
	$base = Pod::L10N::Model::decode($sl);
    }

    {
	my $f = 0;
	for(@$base){
	    if($$_[0] =~ /^=begin meta/){
		$f = 1;
		next;
	    }
	    if($$_[0] =~ /^=end meta/){
		$f = 0;
		next;
	    }
	    if($f == 1){
		$meta .= $$_[0];
		next;
	    }
	    if($$_[0] =~ /^=encoding/){
		$encoding = $$_[0];
		next;
	    }

	    if(!defined $$_[1]){next;}

	    $$_[1] =~ s/\(TBT\).*$//;

	    my @enlist;
	    {
		my $en = $$_[0];
		$en =~ s/\n/ /g;
		$en =~ s/  */ /g;
		$en =~ s/i\.e\./%%%IE%%%/g;
		$en =~ s/e\.g\./%%%EG%%%/g;
		$en =~ s/etc\./%%%ETC%%%/g;
		$en =~ s/\.\.\./%%%TRIPLE%%%/g;
		@enlist = map {
		    my $x = $_;
		    $x =~ s/^ *//;
		    $x =~ s/%%%IE%%%/i\.e\./;
		    $x =~ s/%%%EG%%%/e\.g\./;
		    $x =~ s/%%%ETC%%%/etc\./;
		    $x =~ s/%%%TRIPLE%%%/\.\.\./;
		    $x} split /[.?]/, $en;
	    }
	    my @jplist;
	    {
		my $jp = $$_[1];
		chomp $jp;
		$jp =~ s/\n/ /g;
		$jp =~ s/\(TBT\).*$//;
		$jp =~ s/\.\.\./%%%TRIPLE%%%/g;
		@jplist = map {
		    my $x = $_;
		    $x =~ s/^ *//;
		    $x =~ s/%%%IE%%%/i\.e\./;
		    $x =~ s/%%%EG%%%/e\.g\./;
		    $x =~ s/%%%ETC%%%/etc\./;
		    $x =~ s/%%%TRIPLE%%%/\.\.\./;
		    $x} split /。|\.|\?/, $jp;
	    }

	    if($#enlist != $#jplist){
		for(@enlist){
		    print "$_\n";
		}
		printf "----\n";
		for(@jplist){
		    print "$_\n";
		}
		print "----------------\n";
		next;
	    }
	    while($#enlist >= 0 && $#jplist >= 0){
		my $en = shift @enlist;
		my $jp = shift @jplist;
		my $nowl = $cv{$en};
		if(!defined $nowl){
		    $nowl = [];
		}
		my @l = @{$nowl};
		push @l, $jp;
		$cv{$en} = \@l;
	    }
	}
    }

    for(sort keys %cv){
	my (@l) = @{$cv{$_}};
	if($#l >= 1){
	    my %c;
	    for(@l){
		s/^ *//;
		$c{$_}++;
	    }
	    if(scalar(keys %c) >= 2){
		printf "--------\n%s\n", $_;
		for(keys %c){
		    printf "-\n%d: %s\n", $c{$_}, $_;
		}
	    }
	}
    }
}