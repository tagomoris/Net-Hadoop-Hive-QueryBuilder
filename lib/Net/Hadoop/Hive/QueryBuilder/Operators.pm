package Net::Hadoop::Hive::QueryBuilder::Operators;

use strict;
use warnings;
use Carp;

# operators
# type
# f: formula
# s: sentence
# g: grammer (hql reserved word)
# q: query

sub builtin_operators {
    +[
        { type => 's', name => '=', proc => \&equal_operator },
        { type => 's', name => '!=', proc => \&notequal_operator },
        { type => 's', name => 'in', proc => \&in_operator },
        { type => 's', name => 'not', proc => \&not_operator },
        { type => 's', name => 'and', proc => \&and_operator },
        { type => 's', name => 'or', proc => \&or_operator },
        { type => 's', name => '+', proc => \&plus_operator },
        { type => 's', name => '-', proc => \&minus_operator },
        { type => 'f', name => 'map_get', proc => \&map_get },
        { type => 'f', name => 'map_construct', proc => \&map_construct },
        { type => 'f', name => 'array_get', proc => \&array_get },
        { type => 'f', name => 'array_construct', proc => \&array_construct },
    ]
}

sub plugin_proc {
    my $name = shift;
    foreach my $p (@{builtin_operators()}) {
        if ($p->{name} eq $name) {
            return $p->{proc};
        }
    }
    return undef;
}

sub equal_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'=' accepts just 2 arguments";
    }
    my ($a1, $a2) = @args;
    my @parts;
    my $sep = ($builder->node_name($a2) eq 'null' ? ' IS ' : '=');

    $builder->produce_value($a1) . $sep . $builder->produce_value($a2);
}

sub notequal_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'=' accepts just 2 arguments";
    }
    my ($a1, $a2) = @args;
    my @parts;
    my $sep = ($builder->node_name($a2) eq 'null' ? ' IS NOT ' : '!=');

    $builder->produce_value($a1) . $sep . $builder->produce_value($a2);
}

sub in_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) < 2) {
        die "'in' accepts 2 or more arguments";
    }
    my ($first, @lest) = @args;
    $builder->produce($first) . ' IN (' . join(', ', map { $builder->produce_value($_) } @lest) . ')';
}

sub not_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 1) {
        die "'not' accepts just 1 argument";
    }
    my $arg = shift @args;
    'NOT ' . $builder->produce_value($arg);
}

sub and_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) < 2) {
        die "'and' accepts 2 or more arguments";
    }
    join(' AND ', map { $builder->produce_value($_) } @args);
}

sub or_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) < 2) {
        die "'or' accepts 2 or more arguments";
    }
    join(' OR ', map { $builder->produce_value($_) } @args);
}

# map/array constructor is function, but... hmmm
sub map_construct {
    my ($builder,@args) = @_;
    if (scalar(@args) % 2 != 0) {
        die "'map_construct' needs key-value pairs (but odd number arguments)"
    }
    'map(' . join(', ', map { $builder->produce_value($_) } @args ) . ')';
}

sub array_construct {
    my ($builder,@args) = @_;
    'array(' . join(', ', map { $builder->produce_value($_) } @args ) . ')';
}

sub map_get {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'map_get' accepts just 2 arguments";
    }
    my ($hash, $key) = @args;
    $builder->produce_value($hash) . '[' . $builder->produce_value($key) . ']'
}

sub array_get {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'array_get' accepts just 2 arguments";
    }
    my ($array, $index) = @args;
    $builder->produce_value($array) . '[' . $builder->produce_value($index) . ']'
}

sub plus_operator {
}

sub minus_operator {
}

1;
