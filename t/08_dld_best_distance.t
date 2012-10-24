use Test::Base;
use Text::Levenshtein::Damerau;

plan tests => 1 * blocks;

filters {
    input    => [qw/chomp/],
    expected => [qw/chomp/],
};


run {
	my $block = shift;
	my $tld = Text::Levenshtein::Damerau->new($block->input);
	my @list = ('fuor','forty','for');
	is( $tld->dld_best_distance({ list => \@list }), $block->expected );
};

__END__

=== test1
--- input
four
--- expected
1

=== test2
--- input
for
--- expected
0

=== test3
--- input
forty-seven
--- expected
6

