use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'String::RewritePrefix',
  VERSION_FROM  => 'lib/String/RewritePrefix.pm',
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM     => {
    'Test::More' => '0.47',
    'Sub::Exporter' => 0,
  },
  (eval { ExtUtils::MakeMaker->VERSION(6.46) }
    ? (META_MERGE => {
        resources => {
          Repository => 'http://github.com/rjbs/string-rewriteprefix'
        }
      })
    : ()
  ),
);
