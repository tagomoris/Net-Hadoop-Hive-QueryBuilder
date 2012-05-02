package Net::Hadoop::Hive::QueryBuilder::Functions;

use strict;
use warnings;
use Carp;

# functions

sub builtin_functions {
    [];
}

sub plugin_proc {
    my $name = shift;
    foreach my $p (@{builtin_functions()}) {
        if ($p->{name} eq $name) {
            return $p->{proc};
        }
    }
    return undef;
}

sub hash {
}

sub array {
}

sub if_function {
}

sub count {
}

1;
