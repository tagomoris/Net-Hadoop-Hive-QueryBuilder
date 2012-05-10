package Net::Hadoop::Hive::QueryBuilder::Functions::XPath;

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

#TODO...
sub xpath {}
sub xpath_short {}
sub xpath_int {}
sub xpath_long {}
sub xpath_float {}
sub xpath_double {}
sub xpath_number {}
sub xpath_string {}

1;
