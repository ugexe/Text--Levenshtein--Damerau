package Text::Levenshtein::Damerau;

use utf8;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = '0.09';
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(&edistance &dld);
%EXPORT_TAGS = ();

# For backwards compatability
sub edistance {
	dld(@_);
}

sub dld {
	my ($source,$target) = @_;

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
				$H{$i + 1}{$j + 1} = min($H{$i}{$j}, min($H{$i + 1}{$j}, $H{$i}{$j + 1})) + 1;
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

sub min {
    my ($x, @xs) = @_;
    @xs ? do { my $m = min(@xs); ($x, $m)[$x > $m] } : $x;
}

1;
__END__

=head1 NAME

Text::Levenshtein::Damerau - Damerau Levenshtein edit distance

=head1 SYNOPSIS

  use Text::Levenshtein::Damerau qw(dld);

  print dld("foo","four");
  # prints "2"

  print dld("svee","seven");
  # prints "2"

  print dld("ABC","abC");
  # prints "2"

=head1 DESCRIPTION

Returns the true Damerau Levenshtein edit distance of strings with adjacent transpositions..

=head1 AUTHOR

ugexe <F<ug@skunkds.com>>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut