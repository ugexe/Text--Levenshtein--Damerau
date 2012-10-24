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
	is( $tld->dld_best_match({ list => \@list }), $block->expected );
};

__END__

=== test matching
--- input
four
--- expected
fuor

=== test insertion
--- input
for
--- expected
for

=== test deletion
--- input
forty-seven
--- expected
forty

