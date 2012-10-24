use Test::Base;
use utf8;
use Text::Levenshtein::Damerau qw/edistance/;

plan tests => 1 * blocks;

filters {
    input    => [qw/chomp/],
    expected => [qw/chomp/],
};

run {
	my $block = shift;
	is( edistance('ⓕⓞⓤⓡ',$block->input), $block->expected);
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

=== test empty
--- input

--- expected
4

