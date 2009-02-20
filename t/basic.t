use strict;
use warnings;

use Test::More tests => 2;

use String::RewritePrefix;

my $rewriter = String::RewritePrefix->new_rewriter({
  '-' => 'Tet::',
  '@' => 'KaTet::',
  '+' => sub { $_[0] . '::Foo::' },
});

my @results = $rewriter->(qw(
  -Corporation
  @Roller
  Plinko
  -@Oops
  +Bar
));

is_deeply(
  \@results,
  [ qw(Tet::Corporation KaTet::Roller Plinko Tet::@Oops Bar::Foo::Bar) ],
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

