use Test::Base;
use Text::Levenshtein::Damerau;

plan tests => 3 * blocks;

filters {
    input    => [qw/chomp/],
    expected1 => [qw/chomp/],
    expected2 => [qw/chomp/],
    expected3 => [qw/chomp/],
};


run {
	my $block = shift;
	my $tld = Text::Levenshtein::Damerau->new($block->input);
	my @list = ('four','fourth','fourty');
	my $hash_ref = $tld->dld({ list => \@list});
	is( $hash_ref->{'four'}, $block->expected1 );
	is( $hash_ref->{'fourth'}, $block->expected2 );
	is( $hash_ref->{'fourty'}, $block->expected3 );

};

__END__

=== test matching
--- input
four
--- expected1
0
--- expected2
2
--- expected3
2

=== test insertion
--- input
for
--- expected1
1
--- expected2
3
--- expected3
3

=== test deletion
--- input
fourth
--- expected1
2
--- expected2
0
--- expected3
1

