use strict;
use warnings;
use Data::Dumper;

use Pod::L10N::Model;

my $tc = 0;
my $tok = 0;

for(@ARGV){

    my @slurp;

    {
	open my $f, '<', $_;
	@slurp = (<$f>);
	close $f;
    }


    my $sl = join '', @slurp;
    my $dl = Pod::L10N::Model::decode($sl);
    
    my $c = 0;
    my $ok = 0;
    
    for (@$dl){
	#    if(!defined $_){next;}
	my ($en, $jp) = @$_;
	
	if($en !~ /^=/ && defined $jp){
	    if($jp !~ /TBT/){
		$ok++;
		$tok++;
	    }
	    $c++;
	    $tc++;
	}
    }

    my $ratio;
    if($c == 0){
	$ratio = 0;
    } else {
	$ratio = $ok * 100 / $c;
    }
    printf "%40s %3.0f%% (%d / %d)\n", $_, $ratio, $ok, $c;
}
printf "Total: %3.0f%% (%d / %d)\n", $tok * 100 / $tc, $tok, $tc;

