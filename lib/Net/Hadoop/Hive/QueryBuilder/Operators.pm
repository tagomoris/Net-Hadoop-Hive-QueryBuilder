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
        { type => 's', name => '<', proc => \&less_than_operator },
        { type => 's', name => '<=', proc => \&less_than_or_equal_to_operator },
        { type => 's', name => '>', proc => \&greater_than_operator },
        { type => 's', name => '>=', proc => \&greater_than_or_equal_to_operator },
        { type => 's', name => 'in', proc => \&in_operator },
        { type => 's', name => 'like', proc => \&like },
        { type => 's', name => 'rlike', proc => \&rlike },

        { type => 's', name => '+', proc => \&add_operator },
        { type => 's', name => '-', proc => \&subtract_operator },
        { type => 's', name => '*', proc => \&multiply_operator },
        { type => 's', name => '/', proc => \&divide_operator },
        { type => 's', name => '%', proc => \&reminder_of_divide_operator },
        { type => 's', name => '&', proc => \&bitwise_and_operator },
        { type => 's', name => '|', proc => \&bitwise_or_operator },
        { type => 's', name => '^', proc => \&bitwise_xor_operator },
        { type => 's', name => '~', proc => \&bitwise_not_operator },

        { type => 's', name => 'not', proc => \&not_operator },
        { type => 's', name => 'and', proc => \&and_operator },
        { type => 's', name => 'or', proc => \&or_operator },

        { type => 'f', name => 'map_get', proc => \&map_get },
        { type => 'f', name => 'map_construct', proc => \&map_construct },
        { type => 'f', name => 'array_get', proc => \&array_get },
        { type => 'f', name => 'array_construct', proc => \&array_construct },
        { type => 'f', name => 'struct_get', proc => \&struct_get },
        { type => 'f', name => 'struct_construct', proc => \&struct_construct },
        { type => 'f', name => 'named_struct_construct', proc => \&named_struct_construct },
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
        die "'=' needs just 2 arguments";
    }
    my ($a1, $a2) = @args;
    my @parts;
    my $sep = ($builder->node_name($a2) eq 'null' ? ' IS ' : ' = ');

    $builder->produce_value($a1) . $sep . $builder->produce_value($a2);
}

sub notequal_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'!=' needs just 2 arguments";
    }
    my ($a1, $a2) = @args;
    my @parts;
    my $sep = ($builder->node_name($a2) eq 'null' ? ' IS NOT ' : ' != ');

    $builder->produce_value($a1) . $sep . $builder->produce_value($a2);
}

sub less_than_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'<' needs just 2 arguments";
    }
    my ($a1, $a2) = @args;
    $builder->produce_value($a1) . ' < ' . $builder->produce_value($a2);
}

sub less_than_or_equal_to_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'<=' needs just 2 arguments";
    }
    my ($a1, $a2) = @args;
    $builder->produce_value($a1) . ' <= ' . $builder->produce_value($a2);
}

sub greater_than_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'>' needs just 2 arguments";
    }
    my ($a1, $a2) = @args;
    $builder->produce_value($a1) . ' > ' . $builder->produce_value($a2);
}

sub greater_than_or_equal_to_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'>=' needs just 2 arguments";
    }
    my ($a1, $a2) = @args;
    $builder->produce_value($a1) . ' >= ' . $builder->produce_value($a2);
}

sub in_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) < 2) {
        die "'in' needs 2 or more arguments";
    }
    my ($first, @lest) = @args;
    $builder->produce($first) . ' IN (' . join(', ', map { $builder->produce_value($_) } @lest) . ')';
}

sub like {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'like' needs just 2 arguments";
    }
    my ($val, $exp) = @args;
    unless ($builder->node_name($exp) eq 'string') {
        die "'like' needs string for second argument as like-expression";
    }
    $builder->produce_value($val) . ' LIKE ' . $builder->produce_value($exp);
}

sub rlike {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'rlike' needs just 2 arguments";
    }
    my ($val, $exp) = @args;
    unless ($builder->node_name($exp) eq 'string') {
        die "'rlike' needs string for second argument as regular expression";
    }
    $builder->produce_value($val) . ' RLIKE ' . $builder->produce_value($exp);
}

sub add_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'+' needs just 2 arguments";
    }
    join(' + ', map { $builder->produce_value($_) } @args);
};
sub subtract_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'-' needs just 2 arguments";
    }
    join(' - ', map { $builder->produce_value($_) } @args);
};
sub multiply_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'*' needs just 2 arguments";
    }
    join(' * ', map { $builder->produce_value($_) } @args);
};
sub divide_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'/' needs just 2 arguments";
    }
    join(' / ', map { $builder->produce_value($_) } @args);
};
sub reminder_of_divide_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'%' needs just 2 arguments";
    }
    join(' % ', map { $builder->produce_value($_) } @args);
};
sub bitwise_and_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'&' needs just 2 arguments";
    }
    join(' & ', map { $builder->produce_value($_) } @args);
};
sub bitwise_or_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'|' needs just 2 arguments";
    }
    join(' | ', map { $builder->produce_value($_) } @args);
};
sub bitwise_xor_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'^' needs just 2 arguments";
    }
    join(' ^ ', map { $builder->produce_value($_) } @args);
};
sub bitwise_not_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 1) {
        die "'~' needs just 1 arguments";
    }
    my $arg = shift @args;
    '~' . $builder->produce_value($arg);
};

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
        die "'map_construct' needs key-value pairs (but odd number arguments)";
    }
    'map(' . join(', ', map { $builder->produce_value($_) } @args ) . ')';
}

sub array_construct {
    my ($builder,@args) = @_;
    'array(' . join(', ', map { $builder->produce_value($_) } @args ) . ')';
}

sub struct_construct {
    my ($builder,@args) = @_;
    'struct(' . join(', ', map { $builder->produce_value($_) } @args ) . ')';
}

sub named_struct_construct {
    my ($builder,@args) = @_;
    if (scalar(@args) % 2 != 0) {
        die "'named_struct_construct' needs key-value pairs (but odd number arguments)";
    }
    'named_struct(' . join(', ', map { $builder->produce_value($_) } @args ) . ')';
}

sub map_get {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'map_get' needs just 2 arguments";
    }
    my ($hash, $key) = @args;
    $builder->produce_value($hash) . '[' . $builder->produce_value($key) . ']'
}

sub array_get {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'array_get' needs just 2 arguments";
    }
    my ($array, $index) = @args;
    $builder->produce_value($array) . '[' . $builder->produce_value($index) . ']'
}

sub struct_get {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'struct_get' needs just 2 arguments";
    }
    my ($struct, $attr_sym) = @args;
    unless (ref($attr_sym) eq 'Data::SExpression::Symbol') {
        die "'struct_get' needs attribute name symbol as second argument";
    }
    $builder->produce_value($struct) . '.' . $attr_sym->name;
}

1;
