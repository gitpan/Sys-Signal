use 5.005;

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	=> 'Sys::Signal',
    'VERSION_FROM' => 'Signal.pm', # finds $VERSION
#    'DEFINE' => '-g',
    'dist'    => { 
        PREOP => 'pod2text Signal.pm > README', 
    }, 
);
