use inc::Module::Install; 

name          	'Text-Levenshtein-Damerau';
all_from      	'lib/Text/Levenshtein/Damerau.pm';
readme_from 		'lib/Text/Levenshtein/Damerau.pm', 1;

auto_manifest;
auto_set_repository;
auto_license;


test_requires 'Test::More';
requires 'List::Util';
recommends 'Inline::C' => '0'

 
eval {
    require Inline;
    Inline->import( 	C => Config => BUILD_NOISY => 1 );
};

if($@) {
    WriteAll();
}
else {
    WriteAll( inline => 1 );
}