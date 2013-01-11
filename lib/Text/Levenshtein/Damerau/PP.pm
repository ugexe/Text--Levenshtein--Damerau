package Text::Levenshtein::Damerau::PP;
use 5.008_008; # for utf8, sorry legacy Perls
use strict;
use utf8;

BEGIN {
  require Exporter;
  *{import} = \&Exporter::import;
}

our @EXPORT_OK = qw/pp_edistance/;
our $VERSION = '0.20';

local $@;
eval { require List::Util; };
unless ($@) {
    *min = \&List::Util::min;
}
else {
    *min = \&_min;
}


sub pp_edistance {

    # Does the actual calculation on a pair of strings
    my ( $source, $target, $max_distance ) = @_;
    $max_distance ||= 0;
    $max_distance = 0 unless ( $max_distance =~ m/^\d+$/xms );

    my $m   = length($source);
    my $n   = length($target);
 
    if($m == 0 && $n == 0) {
	return 0;
    }
    elsif($m == 0) {
	return $n;
    }
    elsif($n == 0) {
       return $m;
    }

    my $INF = $m + $n;
    my %H;
    my %sd;

    $H{0}{0} = $INF;
    $H{1}{1} = 0;
    $H{1}{0} = $INF;
    $H{0}{1} = $INF;


    for ( 1 .. $m ) {
        my $i  = $_;
        my $DB = 0;

        $sd{substr( $source, $i - 1, 1 )} = 0;
        $H{ $i + 1 }{1} = $i;
        $H{ $i + 1 }{0} = $INF;

        for ( 1 .. $n ) {
            my $j  = $_;
	      
            if( $i == 1 ) {
                $sd{substr( $target, $j - 1, 1 )} = 0;
	         $H{1}{ $j + 1 } = $j;
       	  $H{0}{ $j + 1 } = $INF;
	     }

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

        unless ( $max_distance == 0 || $max_distance >= $H{ $i + 1 }{ $n + 1 } )
        {
            return -1;
        }

        $sd{ substr( $source, $i - 1, 1 ) } = $i;
    }

    return $H{ $m + 1 }{ $n + 1 };
}

sub _min {
    my $min = shift;
    return $min if not @_;

    my $next = shift;
    unshift @_, $min < $next ? $min : $next;
    goto &_min;
}

sub _null_or_empty {
    my $s = shift;

    if ( defined($s) && $s ne '' ) {
        return 0;
    }

    return 1;
}

1;

__END__

=encoding utf8

=head1 NAME

Text::Levenshtein::Damerau::PP - Pure Perl Damerau Levenshtein edit distance.

=head1 SYNOPSIS

	use Text::Levenshtein::Damerau::PP qw/pp_edistance/;

	print pp_edistance('Neil','Niel');
	# prints 1

=head1 DESCRIPTION

Returns the true Damerau Levenshtein edit distance of strings with adjacent transpositions. Pure Perl implementation. Works correctly with utf8.

	use Text::Levenshtein::Damerau::PP qw/pp_edistance/;
	use utf8;

	pp_edistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 
	# prints 1

=head1 METHODS

=head2 pp_edistance

Arguments: source string and target string. 

=over

=item * I<OPTIONAL 3rd argument> int (max distance; only return results with $int distance or less). 0 = unlimited. Default = 0.

=back

Returns: int that represents the edit distance between the two argument. Stops calculations and returns -1 if max distance is set and reached.

Function to take the edit distance between a source and target string. Contains the actual algorithm implementation. 

	use Text::Levenshtein::Damerau::PP qw/pp_edistance/;
	print pp_edistance('Neil','Niel');
	# prints 1

	print pp_edistance('Neil','Nielx',1);
	# prints -1


=head1 SEE ALSO

=over 4

=item * L<Text::Levenshtein::Damerau>

=item * L<Text::Levenshtein::Damerau::XS>

=back

=head1 BUGS

Please report bugs to:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Text-Levenshtein-Damerau>

=head1 AUTHOR

Nick Logan <F<ug@skunkds.com>>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut


