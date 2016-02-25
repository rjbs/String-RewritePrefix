use strict;
use warnings;
package String::RewritePrefix;

use Carp ();
# ABSTRACT: rewrite strings based on a set of known prefixes

# 0.972 allows \'method_name' form -- rjbs, 2010-10-25
use Sub::Exporter 0.972 -setup => {
  exports => [ rewrite => \'_new_rewriter' ],
};

=head1 SYNOPSIS

  use String::RewritePrefix;
  my @to_load = String::RewritePrefix->rewrite(
    { '' => 'MyApp::', '+' => '' },
    qw(Plugin Mixin Addon +Corporate::Thinger),
  );

  # now you have:
  qw(MyApp::Plugin MyApp::Mixin MyApp::Addon Corporate::Thinger)

You can also import a rewrite routine:

  use String::RewritePrefix rewrite => {
    -as => 'rewrite_dt_prefix',
    prefixes => { '' => 'MyApp::', '+' => '' },
  };

  my @to_load = rewrite_dt_prefix( qw(Plugin Mixin Addon +Corporate::Thinger));

  # now you have:
  qw(MyApp::Plugin MyApp::Mixin MyApp::Addon Corporate::Thinger)

=method rewrite

  String::RewritePrefix->rewrite(\%prefix, @strings);

This rewrites all the given strings using the rules in C<%prefix>.  Its keys
are known prefixes for which its values will be substituted.  This is performed
in longest-first order, and only one prefix will be rewritten.

If the prefix value is a coderef, it will be executed with the remaining string
as its only argument.  The return value will be used as the prefix.

=cut

sub rewrite {
  shift; # $self
  my $rewrites = shift || {};

  Carp::cluck("rewrite invoked in void context")
    unless defined wantarray;

  # Checks for scalar context
  unless (wantarray) {
    if (@_ > 1) {
      Carp::croak("attempt to rewrite multiple strings outside of list context")
    } elsif (@_ == 0) {
      Carp::cluck("rewrite invoked without args")
    }
  }

  my @prefixes = sort { length $b <=> length $a } keys %$rewrites;
  my @result = @_;
  for my $str (@result) {
    for my $pfx (@prefixes) {
      if (index($str, $pfx) == 0) {
        my $repl = $rewrites->{$pfx};
        if (ref $repl) {
          substr($str, 0, length($pfx), '');
          $repl = $repl->($str);
          substr($str, 0, 0, $repl) if defined $repl;
        } else {
          substr($str, 0, length($pfx), $repl)
        }
        last
      }
    }
    return $str unless wantarray;
  }
  @result
}

sub _new_rewriter {
  # my ($self, $name, $arg) = @_;
  my $rewrites = $_[2]->{prefixes} || {};

  my @rewrites =
    map { ($_, $rewrites->{$_}) }
    sort { length $b <=> length $a }
    keys %$rewrites
  ;

  return sub {

    Carp::cluck("string rewriter invoked in void context")
      unless defined wantarray;

    # Checks for scalar context
    unless (wantarray) {
      if (@_ > 1) {
        Carp::croak("attempt to rewrite multiple strings outside of list context")
      } elsif (@_ == 0) {
        Carp::cluck("rewrite invoked without args")
      }
    }

    my @result = @_;
    for my $str (@result) {
      for (my $i = 0; $i < @rewrites; $i += 2) {
        if (index($str, $rewrites[$i]) == 0) {
          if (ref $rewrites[$i+1]) {
            substr($str, 0, length($rewrites[$i]), '');
            my $repl = $rewrites[ $i+1 ]->($str);
            substr($str, 0, 0, $repl) if defined $repl;
          } else {
            substr($str, 0, length($rewrites[$i]), $rewrites[$i+1])
          }
          last
        }
      }
      return $str unless wantarray;
    }
    @result
  };
}

1;
