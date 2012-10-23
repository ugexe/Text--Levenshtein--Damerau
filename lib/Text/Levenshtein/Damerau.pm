package Text::Levenshtein::Damerau;
 
use utf8;
use List::Util qw/reduce min/;

@ISA = qw(Exporter);
@EXPORT_OK = qw(edistance);

our $VERSION = '0.15';

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

	my %tld_hash = $tld->dld(@targets);
	print $tld_hash{'fuor'};
	# prints 1

	print $tld->dld_best_match(@targets);
	# prints fuor

	print $tld->dld_best_distance(@targets);
 	# prints 1

=head1 DESCRIPTION

Returns the true Damerau Levenshtein edit distance of strings with adjacent transpositions.

=head1 CONSTRUCTOR

=head2 new

Creates and returns a Text::Levenshtein::Damerau object. Takes a scalar with the text (source) you want to compare against. 

	my $tld = Text::Levenshtein::Damerau->new('Neil');
	# Creates a new Text::Levenshtein::Damerau object $tld

=cut


sub new {
	my $class = shift;
	my $self = {};

	$self->{'source'} = shift;

	bless($self, $class);

	return $self;
}

=head1 METHODS

=head2 $tld->dld

2 Arguments dld($string): takes a scalar (string to compare against)

Returns: a scalar (the edit distance)

3 Arguments dld(8,$string): takes an int (maximum edit distance to record; default is 8, 0 = unlimited), and an array (of strings to compare against).

Returns: a hash such that $hash{$string_from_list} = $edit_distance 

	my $tld = Text::Levenshtein::Damerau->new('Neil');
	print $tld->dld('Niel'); # prints 1

	#or if you want to check the distance of various items in a list

	my @names_list = ('Neil','Jack');
	my $tld = Text::Levenshtein::Damerau->new('Neil');
	my %distance_hash = $tld->dld(8, @names_list); # pass a list, returns a hash
	print $distance_hash{'Niel'}; #prints 1
	print $distance_hash{'Jack'}; #prints 4

	
=cut

sub dld {
	my $self = shift;
	my $arg1 = shift;
	my @targets = @_;

	my $source = $self->{'source'};
	my %target_score;

	if(!$targets) {
		return edistance($source,$arg1);
	}
	else {
		if($arg1 !~ m/^\d+$/) {
			$arg1 = 8;
		}

		foreach my $target ( @targets ) {
			my $distance = edistance($source,$target);
			
			if($arg1 <= $distance || $arg1 == 0) {
				$target_score{$target} = edistance($source,$target);
			}
		}
	}

	return %target_score;
}

=head2 $tld->dld_best_match

Arguments: an array of strings.

Returns: the string with the smallest edit distance between the source and the array of strings passed.

Takes distance of $tld source against every item in @targets, then returns the string of the best match

	my @name_spellings = ('Niel','Neell','KNiel');
	print $tld->dld_best_match( @name_spellings );
	# prints Niel

=cut

sub dld_best_match {
	my $self = shift;
	my @targets = @_;
	my %hash = $self->dld(@targets);

	return reduce { $hash{$a} < $hash{$b} ? $a : $b } keys %hash;
}

=head2 $tld->dld_best_distance

Arguments: an array of strings.

Returns: the smallest edit distance between the source and the array of strings passed.

Takes distance of $tld source against every item in the passed array, then returns the smallest edit distance.

	my @name_spellings = ('Niel','Neell','KNiel');
	print $tld->dld_best_distance( @name_spellings );
	# prints 1

=cut

sub dld_best_distance {
	my $self = shift;
	my @targets = @_;

	my $best_match = $self->dld_best_match(@targets);
	return $self->dld( $best_match );
}

=head1 EXPORTABLE METHODS

=head2 edistance

Arguments: source string and target string.

Returns: scalar containing int that represents the edit distance between the two argument.

Function to take the edit distance between a source and target string. Contains the actual algorithm implementation 

	use Text::Levenshtein::Damerau qw/edistance/;
	print edistance('Neil','Niel');
	# prints 1

=cut

sub edistance {
	# Does the actual calculation on a pair of strings
	my($source,$target) = @_;
	if( _null_or_empty($source) ) {
		if( _null_or_empty($target) ) {
			return 0;
		}
		else {
			return length($target);
		}
	}
	elsif( _null_or_empty($target) ) {
		return length($source);
	}
	elsif( $source eq $target ) {
		return 0;
	}
	

	my $m = length($source);
	my $n = length($target);
	my $INF = $m + $n;
	my %H;
	$H{0}{0} = $INF;

	for(my $i = 0; $i <= $m; $i++) { $H{$i + 1}{1} = $i; $H{$i + 1}{0} = $INF; }
	for(my $j = 0; $j <= $n; $j++) { $H{1}{$j + 1} = $j; $H{0}{$j + 1} = $INF; }

	my %sd;
	for(my $key = 0; $key < ($m + $n); $key++) {
		my $letter = substr($source . $target, $key-1, 1);
		$sd{$letter} = 0;
	}
	

	for(my $i = 1; $i <= $m; $i++) {
		my $DB = 0;

		for(my $j = 1; $j <= $n; $j++) {
			my $i1 = $sd{substr($target, $j-1, 1)};
			my $j1 = $DB;

			if( substr($source, $i-1, 1) eq substr($target, $j-1, 1) ) {
				$H{$i + 1}{$j + 1} = $H{$i}{$j};
				$DB = $j;
			}
			else {
				$H{$i + 1}{$j + 1} = min($H{$i}{$j}, $H{$i + 1}{$j}, $H{$i}{$j + 1}) + 1;
			}

			$H{$i + 1}{$j + 1} = min($H{$i + 1}{$j + 1}, $H{$i1}{$j1} + ($i - $i1 - 1) + 1 + ($j - $j1 - 1));
		}

		$sd{substr($source, $i-1, 1)} = $i;
	}

	return $H{$m + 1}{$n + 1};
}

sub _null_or_empty {
	my $s = shift;
	
	if( defined($s) && $s ne '') {
		return 0;
	}
	
	return 1;
}

1;
__END__


=head1 SEE ALSO

=over 4

=item * L<https://github.com/ugexe/Text--Levenshtein--Damerau>
=item * L<http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance>

=back

=head1 AUTHOR

ugexe <F<ug@skunkds.com>>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
