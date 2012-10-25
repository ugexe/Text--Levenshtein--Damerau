use inc::Module::Install; 

name          	'Text-Levenshtein-Damerau';
all_from      	'lib/Text/Levenshtein/Damerau.pm';
readme_from 		'lib/Text/Levenshtein/Damerau.pm', 1;

auto_manifest;
auto_set_repository;
auto_license;

test_requires 'Test::Base'; 
test_requires 'Test::More';
requires 'List::Util';
 
WriteAll;