package Net::Hadoop::Hive::QueryBuilder::Functions::Collection;

use strict;
use warnings;
use Carp;

use Data::SExpression::Symbol;

# functions
# type
# f: formula
# s: sentence
# g: grammer (hql reserved word)
# q: query

sub functions {
    +[
#        { type => 'f', name => '', proc => \&foobar },
    ]
}

sub plugin_proc {
    my $name = shift;
    foreach my $p (@{functions()}) {
        if ($p->{name} eq $name) {
            return $p->{proc};
        }
    }
    return undef;
}

# collection functions

sub size_function {
}
sub map_keys {
}
sub map_values {
}
sub array_contains {
}

1;
