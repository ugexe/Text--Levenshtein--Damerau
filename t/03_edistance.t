use strict;
use warnings;

use Test::More tests => 14;
use Text::Levenshtein::Damerau qw/edistance/;;

# If we fail here, but we didn't with pp_edistance, then we know the problem is with ::XS/xs_edistance

is( edistance('four','four'), 	0, 'test edistance matching');
is( edistance('four','for'), 	1, 'test edistance insertion');
is( edistance('four','fourth'), 	2, 'test edistance deletion');
is( edistance('four','fuor'), 	1, 'test edistance transposition');
is( edistance('four','fxxr'), 	2, 'test edistance substitution');
is( edistance('four','FOuR'), 	3, 'test edistance case');
is( edistance('four',''), 		4, 'test edistance target empty');
is( edistance('','four'), 		4, 'test edistance source empty');
is( edistance('',''), 		0, 'test edistance source & target empty');

# Test some utf8
use utf8;
binmode STDOUT, ":encoding(utf8)";
is( edistance('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ'), 	0, 'test edistance matching (utf8)');
is( edistance('ⓕⓞⓤⓡ','ⓕⓞⓡ'), 	1, 'test edistance insertion (utf8)');
is( edistance('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ'), 	2, 'test edistance deletion (utf8)');
is( edistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 	1, 'test edistance transposition (utf8)');
is( edistance('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ'), 	2, 'test edistance substitution (utf8)');

