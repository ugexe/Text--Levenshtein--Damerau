use utf8;
use Test::Base;
use Text::Levenshtein::Damerau;

plan tests => 1 * blocks;

filters {
    input    => [qw/chomp/],
    expected => [qw/chomp/],
};

run {
	my $block = shift;
	my $tld = Text::Levenshtein::Damerau->new('ⓕⓞⓤⓡ');
	is( $tld->dld($block->input), $block->expected );
};

__END__

=== test matching
--- input
ⓕⓞⓤⓡ
--- expected
0

=== test insertion
--- input
ⓕⓞⓡ
--- expected
1

=== test deletion
--- input
ⓕⓞⓤⓡⓣⓗ
--- expected
2

=== test transposition
--- input
ⓕⓤⓞⓡ
--- expected
1

=== test substitution
--- input
ⓕⓧⓧⓡ
--- expected
2
