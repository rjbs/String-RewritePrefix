use strict;
use warnings;

use Test::More tests => 1;

use String::RewritePrefix;

my @to_rewrite = (
    'Foo::Bar' => { arg => 1 },
    'Baz',
);

my @rewritten
    = String::RewritePrefix->rewrite( { '' => 'MyApp::' }, @to_rewrite );

is_deeply \@rewritten,
    [ 'MyApp::Foo::Bar' => { arg => 1 }, 'MyApp::Baz' ],
    "re-writes strings only";

