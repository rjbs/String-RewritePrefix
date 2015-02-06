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

Any non-scalar values in C<@strings> are passed through untouched.

=cut

sub rewrite {
  my ($self, $arg, @rest) = @_;
  return $self->_new_rewriter(rewrite => { prefixes => $arg })->(@rest);
}

sub _new_rewriter {
  my ($self, $name, $arg) = @_;
  my $rewrites = $arg->{prefixes} || {};

  my @rewrites;
  for my $prefix (sort { length $b <=> length $a } keys %$rewrites) {
    push @rewrites, ($prefix, $rewrites->{$prefix});
  }

  return sub {
    my @result;

    Carp::cluck("string rewriter invoked in void context")
      unless defined wantarray;

    Carp::croak("attempt to rewrite multiple strings outside of list context")
      if @_ > 1 and ! wantarray;

    STRING: for my $str (@_) {
      for (my $i = 0; $i < @rewrites; $i += 2) {
        if (!ref $str && index($str, $rewrites[$i]) == 0) {
          if (ref $rewrites[$i+1]) {
            my $rest = substr $str, length($rewrites[$i]);
            my $str  = $rewrites[ $i+1 ]->($rest);
            push @result, (defined $str ? $str : '') . $rest;
          } else {
            push @result, $rewrites[$i+1] . substr $str, length($rewrites[$i]);
          }
          next STRING;
        }
      }

      push @result, $str;
    }
    
    return wantarray ? @result : $result[0];
  };
}

1;
