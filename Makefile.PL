use strict;
require 5.006;
use ExtUtils::MakeMaker;
my $dist = 'String-RewritePrefix';
(my $meta_from = $dist ) =~ s{-}{/}g;
$meta_from = "lib/$meta_from\.pm";
WriteMakefile(
    NAME          => $dist,
    AUTHOR        => 'Ricardo SIGNES <rjbs@cpan.org>',
    ABSTRACT_FROM => $meta_from,
    VERSION_FROM  => $meta_from,
    PREREQ_PM     => {
        'Test::Simple' => 0.47, 
    },
);
