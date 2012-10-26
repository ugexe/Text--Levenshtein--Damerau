##############################################################################
#      $URL: https://github.com/ugexe/Text--Levenshtein--Damerau $
#     $Date: 2012-10-25 20:57:51 -0500 (Thu, 25 Oct 2012) $
#   $Author: ugexe $
# $Revision: 4210 $
##############################################################################

package Text::Levenshtein::Damerau;
use utf8;
use List::Util qw/reduce min/;
use Exporter qw/import/;
our @EXPORT_OK = qw/edistance pp_edistance c_edistance/;

our $VERSION = '0.20';

eval {
    require Inline;
    Inline->import( 	C => Config => BUILD_NOISY => 1 );
    Inline->import( C => <<' EOC');

    int _is_empty (char * text) { 
        if ( strcmp(text, "") == 0 ) {
            return 1; 
        }

        return 0; 
    }

    int _inline_c_edistance (AV* arraySource, AV* arrayTarget) { 
            int i;
        int j;
            int lenSource = av_len(arraySource) ? av_len(arraySource) + 1 : 0;
            int lenTarget = av_len(arrayTarget) ? av_len(arrayTarget) + 1 : 0;
            int areEqual = 1;
        int INF = 1;

            int arrJoined [lenSource + lenTarget];
        int arrSource [ lenSource ];
        int arrTarget [ lenTarget ];

            for (i=1; i <= lenSource; i++) {
                SV** elem = av_fetch(arraySource, i - 1, 0);
                int retval = SvNV(*elem);

                if (elem != NULL) {
                arrJoined[ INF ] = retval;
                        arrSource[ i ] = retval;
                INF++;
                    
                    if (i <= lenTarget && areEqual == 1) {
                    SV** elem2 = av_fetch(arrayTarget, i - 1, 0);
                    int retval2 = SvNV(*elem2);
                    if (elem2 != NULL && retval2 != NULL) {
                                    if (retval2 != retval) {
                            areEqual = 0;
                                    }
                        }
                }
                else {
                        areEqual = 0;
                };
                }
            }
            for (i=1; i <= lenTarget; i++) {
                SV** elem = av_fetch(arrayTarget, i - 1, 0);
            int retval = SvNV(*elem);
                if (elem != NULL) {
                    arrJoined[ INF ] = retval;
                arrTarget[ i ] = retval;
                INF++;
                }
            }

        if ( lenSource == 0) { 
            if ( lenTarget == 0) { 
                return 0; 
            } 
            else { 
                return lenTarget; 
            } 
        } 
        else if ( lenTarget == 0) { 
            return lenSource; 
        } 
        else if ( lenSource == lenTarget && areEqual == 1 ) { 
            return 0; 
        }

        int H [INF][INF]; 
        
        H[0][0] = INF;

        for (i = 0; i <= lenSource; i++) { 
            H[i + 1][1] = i; 
            H[i + 1][0] = INF; 
        } 
        for (j = 0; j <= lenTarget; j++) { 
            H[1][j + 1] = j; 
            H[0][j + 1] = INF; 
        }

        int sd[30000]; 

        i = 0;
        for (i = 1; i < INF; i++) { 
            sd[ arrJoined[ i ] ] = 0; 
        } 

        for (i = 1; i <= lenSource; i++) { 
            int DB = 0;

            for (j = 1; j <= lenTarget; j++) { 
                int i1 = sd[ arrTarget[j]]; 
                int j1 = DB;

                if( arrSource[i] == arrTarget[j] ) { 
                    H[i + 1][j + 1] = H[i][j]; 
                    DB = j; 
                } 
                else { 
                    H[i + 1][j + 1] = _minc(H[i][j], _minc(H[i + 1][j], H[i][j + 1])) + 1; 
                } 
                
                H[i + 1][j + 1] = _minc(H[i + 1][j + 1], H[i1][j1] + (i - i1 - 1) + 1 + (j - j1 - 1));
            }

            sd[ arrSource[i] ] = i; 
        }

        return H[lenSource + 1][lenTarget + 1];
    }

    int _minc (int x, int m ) { 
        if (x < m) { 
            return x; 
        } 
        else { 
            return m; 
        } 
    }

 EOC
};

# Check if require Inline errored. If it did, use the Pure Perl algorithm. Otherwise use the Inline::C algorithm.
if ($@) {
    *edistance = \&pp_edistance;
}
else {
    *edistance = \&c_edistance;
}

sub c_edistance {

    # Wrapper for C edistance function
    my $str1 = shift;
    my $str2 = shift;
    my @arr1 = unpack 'U*', $str1;
    my @arr2 = unpack 'U*', $str2;

    return _inline_c_edistance( \@arr1, \@arr2 );
}

sub pp_edistance {

    # Does the actual calculation on a pair of strings
    my ( $source, $target ) = @_;
    if ( _null_or_empty($source) ) {
        if ( _null_or_empty($target) ) {
            return 0;
        }
        else {
            return length($target);
        }
    }
    elsif ( _null_or_empty($target) ) {
        return length($source);
    }
    elsif ( $source eq $target ) {
        return 0;
    }

    my $m   = length($source);
    my $n   = length($target);
    my $INF = $m + $n;
    my %H;
    $H{0}{0} = $INF;

    for ( 0 ... $m ) {
        my $i = $_;
        $H{ $i + 1 }{1} = $i;
        $H{ $i + 1 }{0} = $INF;
    }
    for ( 0 .. $n ) {
        my $j = $_;
        $H{1}{ $j + 1 } = $j;
        $H{0}{ $j + 1 } = $INF;
    }

    my %sd;
    for ( 0 .. ( $m + $n ) ) {
        my $letter = substr( $source . $target, $_ - 1, 1 );
        $sd{$letter} = 0;
    }

    for ( 1 .. $m ) {
        my $i  = $_;
        my $DB = 0;

        for ( 1 .. $n ) {
            my $j  = $_;
            my $i1 = $sd{ substr( $target, $j - 1, 1 ) };
            my $j1 = $DB;

            if ( substr( $source, $i - 1, 1 ) eq substr( $target, $j - 1, 1 ) )
            {
                $H{ $i + 1 }{ $j + 1 } = $H{$i}{$j};
                $DB = $j;
            }
            else {
                $H{ $i + 1 }{ $j + 1 } =
                  min( $H{$i}{$j}, $H{ $i + 1 }{$j}, $H{$i}{ $j + 1 } ) + 1;
            }

            $H{ $i + 1 }{ $j + 1 } = min( $H{ $i + 1 }{ $j + 1 },
                $H{$i1}{$j1} + ( $i - $i1 - 1 ) + 1 + ( $j - $j1 - 1 ) );
        }

        $sd{ substr( $source, $i - 1, 1 ) } = $i;
    }

    return $H{ $m + 1 }{ $n + 1 };
}

sub new {
    my $class = shift;
    my $self  = {};

    $self->{'source'} = shift;

    bless( $self, $class );

    return $self;
}

sub dld {
    my $self = shift;
    my $args = shift;

    if ( !ref $args ) {
        return edistance( $self->{'source'}, $args );
    }
    elsif ( ref $args->{'list'} eq ref [] ) {
        my $target_score;
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
        my $best_match = $self->dld_best_match( { list => $args->{'list'} } );
        return $self->dld($best_match);
    }
}

sub _null_or_empty {
    my $s = shift;

    if ( defined($s) && $s ne {} ) {
        return 0;
    }

    return 1;
}

1;

__END__

=head1 NAME

C<Text::Levenshtein::Damerau> - Damerau Levenshtein edit distance

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

=head1 DESCRIPTION

Returns the true Damerau Levenshtein edit distance of strings with adjacent transpositions.

Will use L<Inline::C> methods for speed increases if Inline::C and a proper C compiler are installed. Otherwise it falls back to a slower, Pure Perl implementation.

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

=item * I<OPTIONAL> max_distance => $int (only return results with a $int distance or less)

=back

Returns: hashref with each word from the passed list as keys, and their edit distance (if less than max_distance, which is unlimited by default).

	my $tld = Text::Levenshtein::Damerau->new('Neil');
	print $tld->dld( 'Niel' ); # prints 1

	#or if you want to check the distance of various items in a list

	my @names_list = ('Neil','Jack');
	my $tld = Text::Levenshtein::Damerau->new('Neil');
	my $d_ref = $tld->dld({ list=> \@names_list }); # pass a list, returns a hash
	print $d_ref->{'Niel'}; #prints 1
	print $d_ref->{'Jack'}; #prints 4

=head2 $tld->dld_best_match

Argument: an array reference of strings.

Returns: the string with the smallest edit distance between the source and the array of strings passed.

Takes distance of $tld source against every item in @targets, then returns the string of the best match.

	my @name_spellings = ('Niel','Neell','KNiel');
	print $tld->dld_best_match({ list=> \@name_spellings });
	# prints Niel

=head2 $tld->dld_best_distance

Arguments: an array reference of strings.

Returns: the smallest edit distance between the source and the array reference of strings passed.

Takes distance of $tld source against every item in the passed array, then returns the smallest edit distance.

	my @name_spellings = ('Niel','Neell','KNiel');
	print $tld->dld_best_distance({ list => \@name_spellings });
	# prints 1

=head1 EXPORTABLE METHODS

=head2 edistance

Arguments: source string and target string.

Returns: scalar containing int that represents the edit distance between the two argument.

Function to take the edit distance between a source and target string. Contains the actual algorithm implementation. Automatically uses c_edistance of possible, otherwise it falls back to pp_edistance.

	use Text::Levenshtein::Damerau qw/edistance/;
	print edistance('Neil','Niel');
	# prints 1

=head2 pp_edistance

B<SEE edistance> Pure Perl implementation of edistance.

=head2 c_edistance

B<SEE edistance> Wrapper for Inline::C implementation of edistance. Much faster than edistance, but requires Inline::C and a C compiler.

=head1 SEE ALSO

=over 4

=item * L<https://github.com/ugexe/Text--Levenshtein--Damerau>

=item * L<http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance>

=back

=head1 BUGS

Please report bugs to:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Text-Levenshtein-Damerau>

=head1 NOTES

For informational and learning purposes the L<Inline::C> Damerau Levenshtein algorithm implementated mirrors the Perl implementation as much as possible.

=head1 AUTHOR

ugexe <F<ug@skunkds.com>>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut


