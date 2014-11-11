package Text::Levenshtein::Damerau::PP;
use 5.008_008;    # for utf8, sorry legacy Perls
use strict;
use List::Util qw/min max/;
require Exporter;
 
our @ISA = qw(Exporter);
our @EXPORT_OK = qw/pp_edistance/;
our $VERSION   = '0.26';


sub pp_edistance {
    my ( $source, $target, $max ) = @_;
    my $maxd = (defined $max && $max >= 0) ? $max : max(length($source), length($target));

    my $sourceLength = length($source) || 0;
    my $targetLength = length($target) || 0;
    my (@currentRow, @previousRow, @transpositionRow);

    # Swap source/target so that $sourceLength always contains the shorter string
    if ($sourceLength > $targetLength) {
        ($source,$target)             = ($target,$source);
        ($sourceLength,$targetLength) = ($targetLength,$sourceLength);
    }

    return ((!defined $max || $maxd <= $targetLength)
        ? $targetLength : -1) if($sourceLength == 0 || $targetLength == 0);

    my $diff = $targetLength - $sourceLength;
    return -1 if defined $max && $diff > $maxd;
    
    $previousRow[$_] = $_ for 0..$sourceLength+1;

    my $lastTargetCh = '';
    foreach my $i  (1..$targetLength) {
        my $targetCh   = substr($target, $i - 1, 1);
        $currentRow[0] = $i;
        my $start      = max($i - $maxd - 1, 1);
        my $end        = min($i + $maxd + 1, $sourceLength);

        my $lastSourceCh = '';
        foreach my $j ($start..$end) {
            my $sourceCh = substr($source, $j - 1, 1);
            my $cost     = $sourceCh eq $targetCh ? 0 : 1;

            $currentRow[$j] = min(
                $currentRow[$j - 1] + 1, 
                $previousRow[$j >= scalar @previousRow ? -1 : $j] + 1,
                $previousRow[$j - 1] + $cost,
                    ($sourceCh eq $lastTargetCh && $targetCh eq $lastSourceCh)
                        ? $transpositionRow[$j - 2] + $cost
                        : $maxd + 1
                );

            $lastSourceCh = $sourceCh;
        }

        $lastTargetCh = $targetCh;

        my @tempRow       = @transpositionRow;
        @transpositionRow = @previousRow;
        @previousRow      = @currentRow;
        @currentRow       = @tempRow;
    }

    return (!$max.defined || $previousRow[$sourceLength] <= $maxd) ? $previousRow[$sourceLength] : -1;
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


