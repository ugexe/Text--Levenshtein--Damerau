package Text::Levenshtein::Damerau;
use Text::Levenshtein::Damerau::PP;
use strict;
use utf8;
use List::Util qw/reduce/;
use Exporter qw/import/;

our @EXPORT_OK = qw/edistance/;
our $VERSION = '0.27';


# To XS or not to XS...
eval {
	require Text::Levenshtein::Damerau::XS;
};
if($@) {
  # Included in distro
  _set_backend('Text::Levenshtein::Damerau::PP::pp_edistance');
}
else {
  _set_backend('Text::Levenshtein::Damerau::XS::xs_edistance');
}



sub new {
    my $class = shift;
    my $self  = {};

    $self->{'source'} = shift;
    

    bless( $self, $class );

    return $self;
}

sub _set_backend {
  my $be = shift;
  my $module = $be;
  $module =~ s/^(.*)::.*?$/$1/g;

  # Does the module exist?
  eval "require $module";
  unless($@) {
       # Does the module have such a function?
  	eval "defined &$be";
	unless($@) {
		# Does the function return a number if we give it 2 strings?
		eval "die unless(&$be('four','fuor') =~ /[-+]?[0-9]*\.?[0-9]+/)";
		unless($@) {
			# We welcome out new edistance overlord
	  		*edistance = \&$be;
		}
	}
  }
}

sub dld {
    my $self = shift;
    my $args = shift;

    if ( !ref $args ) {
        return edistance( $self->{'source'}, $args );
    }
    elsif ( ref $args->{'list'} eq ref [] ) {
        my $target_score;

        if( defined($args->{'backend'}) ) {
	     _set_backend($args->{'backend'});
        }

	
        foreach my $target ( @{ $args->{'list'} } ) {
            my $distance = edistance( $self->{'source'}, $target );

            if ( !defined( $args->{max_distance} ) ) {
                $target_score->{$target} =
                  edistance( $self->{'source'}, $target );
            }
            elsif ( $args->{max_distance} !~ m/^\d+$/xms ) {
                $target_score->{$target} =
                  edistance( $self->{'source'}, $target );
            }
            elsif ( $distance <= $args->{max_distance} ) {
                $target_score->{$target} =
                  edistance( $self->{'source'}, $target );
            }
        }

        return $target_score;

    }

}

sub dld_best_match {
    my $self = shift;
    my $args = shift;

    if ( defined( $args->{'list'} ) ) {
        my $hash_ref = $self->dld($args);
        return reduce { $hash_ref->{$a} < $hash_ref->{$b} ? $a : $b }
        keys %{$hash_ref};
    }
}

sub dld_best_distance {
    my $self = shift;
    my $args = shift;

    if ( defined( $args->{'list'} ) ) {
        my $best_match = $self->dld_best_match($args);
        return $self->dld($best_match);
    }
}

1;

__END__

=encoding utf8

=head1 NAME

C<Text::Levenshtein::Damerau> - Damerau Levenshtein edit distance.

=head1 SYNOPSIS

	use Text::Levenshtein::Damerau;
	use warnings;
	use strict;

	my @targets = ('fuor','xr','fourrrr','fo');

	# Initialize Text::Levenshtein::Damerau object with text to compare against
	my $tld = Text::Levenshtein::Damerau->new('four');

	print $tld->dld($targets[0]);
	# prints 1

	my $tld = $tld->dld({ list => \@targets });
	print $tld->{'fuor'};
	# prints 1

	print $tld->dld_best_match({ list => \@targets });
	# prints fuor

	print $tld->dld_best_distance({ list => \@targets });
 	# prints 1


	# or even more simply
	use Text::Levenshtein::Damerau qw/edistance/;
	use warnings;
	use strict;
	
	print edistance('Neil','Niel');
	# prints 1

=head1 DESCRIPTION

Returns the true Damerau Levenshtein edit distance of strings with adjacent transpositions. Defaults to using Pure Perl L<Text::Levenshtein::Damerau::PP>, but has an XS addon L<Text::Levenshtein::Damerau::XS> for massive speed imrovements. Works correctly with utf if backend supports it; known to work with C<Text::Levenshtein::Damerau::PP> and C<Text::Levenshtein::Damerau::XS>.

	use utf8;
	my $tld = Text::Levenshtein::Damerau->new('ⓕⓞⓤⓡ');
	print $tld->dld('ⓕⓤⓞⓡ');
	# prints 1

=head1 CONSTRUCTOR

=head2 new

Creates and returns a C<Text::Levenshtein::Damerau> object. Takes a scalar with the text (source) you want to compare against. 

	my $tld = Text::Levenshtein::Damerau->new('Neil');
	# Creates a new Text::Levenshtein::Damerau object $tld

=head1 METHODS

=head2 $tld->dld

B<Scalar> Argument: Takes a string to compare with.

Returns: an integer representing the edit distance between the source and the passed argument.

B<Hashref> Argument: Takes a hashref containing:

=over 4

=item * list => \@array (array ref of strings to compare with)

=item * I<OPTIONAL> max_distance => $int (only return results with $int distance or less).

=item * I<OPTIONAL> backend => 'Some::Module::its_function' Any module that will take 2 arguments and returns an int. If the module fails to load, the function doesn't exist, or the function doesn't return a number when passed 2 strings, then C<backend> remains unchanged. 

	# Override defaults and use Text::Levenshtein::Damerau::PP's pp_edistance()
	$tld->dld({ list=> \@list, backend => 'Text::Levenshtein::Damerau::PP::pp_edistance');

	# Override defaults and use Text::Levenshtein::Damerau::XS's xs_edistance()
	use Text::Levenshtein::Damerau;
	requires Text::Levenshtein::Damerau::XS;
	...
	$tld->dld({ list=> \@list, backend => 'Text::Levenshtein::Damerau::XS::xs_edistance');

=back

Returns: hashref with each word from the passed list as keys, and their edit distance (if less than max_distance, which is unlimited by default).

	my $tld = Text::Levenshtein::Damerau->new('Neil');
	print $tld->dld( 'Niel' );
	# prints 1

	#or if you want to check the distance of various items in a list

	my @names_list = ('Niel','Jack');
	my $tld = Text::Levenshtein::Damerau->new('Neil');
	my $d_ref = $tld->dld({ list=> \@names_list }); # pass a list, returns a hash
	print $d_ref->{'Niel'}; #prints 1
	print $d_ref->{'Jack'}; #prints 4

=head2 $tld->dld_best_match

Argument: an array reference of strings.

Returns: the string with the smallest edit distance between the source and the array of strings passed.

Takes distance of $tld source against every item in @targets, then returns the string of the best match.

	my $tld = Text::Levenshtein::Damerau->new('Neil');
	my @name_spellings = ('Niel','Neell','KNiel');
	print $tld->dld_best_match({ list=> \@name_spellings });
	# prints Niel

=head2 $tld->dld_best_distance

Arguments: an array reference of strings.

Returns: the smallest edit distance between the source and the array reference of strings passed.

Takes distance of $tld source against every item in the passed array, then returns the smallest edit distance.

	my $tld = Text::Levenshtein::Damerau->new('Neil');
	my @name_spellings = ('Niel','Neell','KNiel');
	print $tld->dld_best_distance({ list => \@name_spellings });
	# prints 1

=head1 EXPORTABLE METHODS

=head2 edistance

Arguments: source string and target string.

Returns: scalar containing int that represents the edit distance between the two argument.

Wrapper function to take the edit distance between a source and target string. It will attempt to use, in order: 

=over 4

=item * L<Text::Levenshtein::Damerau::XS> B<xs_edistance>

=item * L<Text::Levenshtein::Damerau::PP> B<pp_edistance>

=back

	use Text::Levenshtein::Damerau qw/edistance/;
	print edistance('Neil','Niel');
	# prints 1

=head1 SEE ALSO

=over 4

=item * L<https://github.com/ugexe/Text--Levenshtein--Damerau> I<repository>

=item * L<http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance> I<damerau levenshtein explaination>

=item * L<Text::Fuzzy> I<regular levenshtein distance>

=back

=head1 BUGS

Please report bugs to:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Text-Levenshtein-Damerau>

=head1 AUTHOR

Nick Logan (ugexe) <F<ug@skunkds.com>>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut


