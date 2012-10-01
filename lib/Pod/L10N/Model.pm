package Pod::L10N::Model;

sub decode {
    my $ss = $_[0];
    $ss =~ s/\n{3,}/\n\n/g;
    $ss =~ s/\n$//;
    my @sp = split /\n\n/, $ss;
    
    my @enjp = ();
    my $f = 0;
    my $en;
    my $jp;
    my $c = 0;
    my $com;
    
    for (@sp){
	s/^\n*//;

	if($f == 10){
	    if(/^[(].+[)]$/){ #
		push @enjp, [$com, $_];
		$f = 0;
		next;
	    }
	    $f = 0;
	}

	if(/^=begin original/){
	    $f = 1;
	    $c = 0;
	    next;
	}
	if (/^=end original/){
	    $f = 2;
	    if($c == 0){
		my ($en1, $jp1) = @{pop @enjp};
		die "$en1\n--\n$jp1\n";
	    }
	    next;
	}
	if (/^=head/ || /^=item/){
	    $f = 10;
	    $com = $_;
	    next;
	}
	
	if($f == 1){
	    $en .= $_;
	    $c++;
	    next;
	}
	
	if($f == 2){
	    $jp .= $_;
	    $c--;
	    if($c == 0){
		push @enjp, [$en, $jp];
		$en = '';
		$jp = '';
		$f = 0;
	    }
	    next;
	}
	
	if($f == 0){
	    push @enjp, [$_, undef];
	}
    }

    return \@enjp;
}

1;

