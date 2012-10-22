use inc::Module::Install;

name          	'Text-Levenshtein-Damerau';
all_from      	'lib/Text/Levenshtein/Damerau.pm';
auto_manifest;

test_requires 'Test::Base'; 
test_requires 'Test::More';
 
WriteAll;