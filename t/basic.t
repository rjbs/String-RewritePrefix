use strict;
use warnings;

use Test::More tests => 2;

use String::RewritePrefix;

my $rewriter = String::RewritePrefix->new_rewriter({
  '-' => 'Tet::',
  '@' => 'KaTet::',
});

my @results = $rewriter->(qw(
  -Corporation
  @Roller
  Plinko
  -@Oops
));

is_deeply(
  \@results,
  [ qw(Tet::Corporation KaTet::Roller Plinko Tet::@Oops) ],
  "rewrote prefices",
);


my @to_load = String::RewritePrefix->rewrite(
  { '' => 'MyApp::', '+' => '' },
  qw(Plugin Mixin Addon +Corporate::Thinger),
);

is_deeply(
  \@to_load,
  [ qw(MyApp::Plugin MyApp::Mixin MyApp::Addon Corporate::Thinger) ],
  "from synopsis, code okay",
);

