use inc::Module::Install; 

name          	'Text-Levenshtein-Damerau';
all_from      	'lib/Text/Levenshtein/Damerau.pm';
author			'ugexe';
repository		'https://github.com/ugexe/Text--Levenshtein--Damerau';
license		'perl';

#readme_from 		'lib/Text/Levenshtein/Damerau.pm', 1;
#auto_manifest;
#auto_set_repository;
#auto_license;


test_requires 'Test::More';
requires 'List::Util';
recommends 'Text::Levenshtein::Damerau::XS';

 
WriteAll();
