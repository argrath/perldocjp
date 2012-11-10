use strict;
use warnings;
use Data::Dumper;

use Pod::L10N::Model;

{
    my %cv;
    my $encoding = '';
    my $meta = '';

    my $outfile = pop @ARGV;

    my $base;
    {
	my $sl = '';
	for(@ARGV){
	    open my $f1, '<', $_ or die "$_: $!";
	    my @slurp = (<$f1>);
	    close $f1;
	    $sl .= join '', @slurp;
	    $sl .= "\n"
	}
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
	    if(defined $cv{$$_[0]} && $cv{$$_[0]} ne $$_[1]){
		warn "$ARGV[0]:\n$$_[0]\n----\n$cv{$$_[0]}\n----\n$$_[1]\n";
	    } else {
		$cv{$$_[0]} = $$_[1];
	    }
	}
    }

    my @sp;
    {
	open my $f2, '<', $outfile or die "$outfile: $!";
	my @slurp = (<$f2>);
	my $ss = join '', @slurp;
	$ss =~ s/\n{3,}/\n\n/g;
	$ss =~ s/\n*$//;
	@sp = split /\n\n/, $ss;
	close $f2;
    }

    print "\n";
    if($encoding ne ''){
	print "$encoding\n\n";
    }

    for (@sp){
	s/^\n*//;

	if(!exists($cv{$_})){
	    my $put;
	    if(/^[ =\t]/){
		$put = $_ . "\n\n";
	    } else {
		$put = sprintf "=begin original\n\n%s\n\n=end original\n\n%s\n(TBT)\n\n",
		$_, $_;
	    }
	    print $put;
	    next;
	}

	my $x = $cv{$_};
	my $put;
	if(defined($x)){
	    if(/^=/){
		$put = sprintf "%s\n\n%s\n\n",
		$_, $x;
	    } else {
		$put = sprintf "=begin original\n\n%s\n\n=end original\n\n%s\n\n",
		$_, $x;
	    }
	} else {
#	    if(/^[ =\t]/){
		$put = $_ . "\n\n";
#	    } else {
#		$put = sprintf "=begin original\n\n%s\n\n=end original\n\n%s\n(TBT)\n\n",
#		$_, $_;
#	    }
	}
	print $put;
    }

    if($meta ne ''){
	print "=begin meta\n\n$meta\n\n=end meta\n\n";
    }
}
