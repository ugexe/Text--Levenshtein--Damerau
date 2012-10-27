use strict;
use warnings;

use Test::More tests => 14;
use Text::Levenshtein::Damerau::PP qw/pp_edistance/;;

is( pp_edistance('four','four'), 0, 'test pp_edistance matching');
is( pp_edistance('four','for'), 1, 'test pp_edistance insertion');
is( pp_edistance('four','fourth'), 2, 'test pp_edistance deletion');
is( pp_edistance('four','fuor'), 1, 'test pp_edistance transposition');
is( pp_edistance('four','fxxr'), 2, 'test pp_edistance substitution');
is( pp_edistance('four','FOuR'), 3, 'test pp_edistance case');
is( pp_edistance('four',''), 4, 'test pp_edistance target empty');
is( pp_edistance('','four'), 4, 'test pp_edistance source empty');
is( pp_edistance('',''), 0, 'test pp_edistance source & target empty');

# Test some utf8
use utf8;
binmode STDOUT, ":encoding(utf8)";
is( pp_edistance('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ'), 0, 'test pp_edistance matching (utf8)');
is( pp_edistance('ⓕⓞⓤⓡ','ⓕⓞⓡ'), 1, 'test pp_edistance insertion (utf8)');
is( pp_edistance('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ'), 2, 'test pp_edistance deletion (utf8)');
is( pp_edistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 1, 'test pp_edistance transposition (utf8)');
is( pp_edistance('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ'), 2, 'test pp_edistance substitution (utf8)');

