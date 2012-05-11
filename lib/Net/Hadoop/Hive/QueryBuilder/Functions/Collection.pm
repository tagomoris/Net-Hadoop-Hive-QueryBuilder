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
        { type => 'f', name => 'size', proc => \&size_function },
        { type => 'f', name => 'map_keys', proc => \&map_keys },
        { type => 'f', name => 'map_values', proc => \&map_values },
        { type => 'f', name => 'array_contains', proc => \&array_contains },
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
    my ($b,@args) = @_;
    if (scalar(@args) != 1 ) { die "(size (map x)) or (size (array x))"; }
    'size(' . $b->produce_value($args[0]) . ')';
}
sub map_keys {
    my ($b,@args) = @_;
    if (scalar(@args) != 1 ) { die "(map_keys (map x))"; }
    'map_keys(' . $b->produce_value($args[0]) . ')';
}
sub map_values {
    my ($b,@args) = @_;
    if (scalar(@args) != 1 ) { die "(map_values (map x))"; }
    'map_values(' . $b->produce_value($args[0]) . ')';
}
sub array_contains {
    my ($b,@args) = @_;
    if (scalar(@args) != 2 ) { die "(array_contains (array x))"; }
    'array_contains(' . $b->produce_value($args[0]) . ', ' . $b->produce_value($args[1]) . ')';
}

1;
