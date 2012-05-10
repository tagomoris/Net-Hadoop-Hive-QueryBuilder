package Net::Hadoop::Hive::QueryBuilder::Functions::Mathematical;

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

sub round {
}
sub floor {
}
sub ceil {
}
sub rand_function {
}
sub exp_function {
}
sub ln {
}
sub log10 {
}
sub log2 {
}
sub log_function {
}
sub pow {
}
sub sqrt_function {
}
sub bin {} #TODO
sub hex_function {} #TODO
sub unhex_function {} #TODO
sub conv {} #TODO
sub abs_function {
}
sub pmod {
}

sub sin_function {} #TODO
sub asin_function {} #TODO
sub cos_function {} #TODO
sub acos_function {} #TODO
sub tan_function {} #TODO
sub atan_function {} #TODO

sub degrees {
}
sub radians {
}
sub positive {
}
sub negative {
}
sub sign {
}
sub e_function {
}
sub pi_function {
}

1;
