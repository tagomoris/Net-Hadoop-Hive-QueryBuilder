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
    foreach $a ($a1, $a2) {
        my $type = $builder->node_type($a);
        if ($type eq 'f') {
            push @parts, $builder->produce($a);
        }
        elsif ($type eq 's') {
            push @parts, '(' . $builder->produce($a) . ')';
        }
        else {
            die "'=' accepts formula or sentence";
        }
    }
    join($sep, @parts);
}

sub notequal_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 2) {
        die "'=' accepts just 2 arguments";
    }
    my ($a1, $a2) = @args;
    my @parts;
    my $sep = ($builder->node_name($a2) eq 'null' ? ' IS NOT ' : '!=');
    foreach $a ($a1, $a2) {
        my $type = $builder->node_type($a);
        if ($type eq 'f') {
            push @parts, $builder->produce($a);
        }
        elsif ($type eq 's') {
            push @parts, '(' . $builder->produce($a) . ')';
        }
        else {
            die "'=' accepts formula or sentence";
        }
    }
    join($sep, @parts);
}

sub in_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) < 2) {
        die "'in' accepts 2 or more arguments";
    }
    my ($first, @lest) = @args;
    my @parts;
    foreach my $p (@lest) {
        my $type = $builder->node_type($p);
        if ($type eq 'f') {
            push @parts, $builder->produce($p);
        }
        elsif ($type eq 's') {
            push @parts, '(' . $builder->produce($p) . ')';
        }
        else {
            die "'in' accepts formula or sentence";
        }
    }
    $builder->produce($first) . ' IN (' . join(', ', @parts) . ')';
}

sub not_operator {
    my ($builder,@args) = @_;
    if (scalar(@args) != 1) {
        die "'not' accepts just 1 argument";
    }
    my $arg = shift @args;
    my $type = $builder->node_type($arg);
    if ($type eq 'f') {
        return 'NOT ' . $builder->produce($arg);
    }
    elsif ($type eq 's') {
        return 'NOT (' . $builder->produce($arg) . ')';
    }
    else {
       die "'not' accepts formula or sentence";
    }
}

sub and_operator {
}

sub or_operator {
}

sub plus_operator {
}

sub minus_operator {
}

1;
