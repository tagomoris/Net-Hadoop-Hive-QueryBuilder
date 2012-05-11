package Net::Hadoop::Hive::QueryBuilder::Functions;

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

use Net::Hadoop::Hive::QueryBuilder::Functions::Mathematical;
use Net::Hadoop::Hive::QueryBuilder::Functions::Collection;
use Net::Hadoop::Hive::QueryBuilder::Functions::Data;
use Net::Hadoop::Hive::QueryBuilder::Functions::String;
#use Net::Hadoop::Hive::QueryBuilder::Functions::XPath;
use Net::Hadoop::Hive::QueryBuilder::Functions::Aggregate;

sub builtin_functions {
    +[
        @{Net::Hadoop::Hive::QueryBuilder::Functions::Mathematical::functions()},
        @{Net::Hadoop::Hive::QueryBuilder::Functions::Collection::functions()},
        { type => 'f', name => 'cast', proc => \&cast },
        @{Net::Hadoop::Hive::QueryBuilder::Functions::Data::functions()},
        { type => 'f', name => 'if', proc => \&if_function },
        { type => 'f', name => 'coalesce', proc => \&coalesce },
        { type => 'f', name => 'case', proc => \&case_function },
        @{Net::Hadoop::Hive::QueryBuilder::Functions::String::functions()},
#        @{Net::Hadoop::Hive::QueryBuilder::Functions::XPath::functions()},
        @{Net::Hadoop::Hive::QueryBuilder::Functions::Aggregate::functions()},
    ]
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

# type conversion

sub cast {
    my ($b,@args) = @_;
    if (scalar(@args) != 2) { die "(cast (value exp) TYPE_SYM)"; }
    'CAST(' . $b->produce_value($args[0]) . ' as ' . uc($args[1]->name) . ')';
}

# conditional functions

sub if_function {
    my ($b,@args) = @_;
    if (scalar(@args) != 3) { die "(if (condition) (valueTrue) (valueFalseOrNull))"; }
    'IF(' . join(', ', map { $b->produce_value($_) } @args) . ')';
}

sub coalesce {
    my ($b,@args) = @_;
    if (scalar(@args) < 1) { die "(coalesce (value1) (value2) ...)"; }
    'COALESCE(' . join(', ', map { $b->produce_value($_) } @args) . ')';
}

sub case_function {
    # for when and else, try hard in this function only....
    # (case (condition) (when (exp) (then_value)) (when (exp) (then_value)) ... (else (else_value)))
    # (case (when (exp) (then_value)) ... (else (else_value)))
    my ($b,@args) = @_;
    if (scalar(@args) < 1) {
        die "(case (condition) (when (exp) (then_value)) (when ...) (else (else_value))) or (case (when ...) ...)";
    }
    my @parts;
    my $cond = '';
    my $first_node_name = $b->node_name($args[0]);
    if ($first_node_name ne 'when' and $first_node_name ne 'else') {
        my $cond_exp = shift @args;
        $cond = $b->produce_value($cond_exp);
    }
    my $else_exists = 0;
    foreach my $a (@args) {
        my $nodename = $b->node_name($a);
        my ($sym, @c_args) = @$a;
        if ($nodename eq 'when') {
            push @parts, when_function($b, @c_args);
        }
        elsif ($nodename eq 'else') {
            if ($else_exists) {
                die "for case, 'else' can be used only once";
            }
            push @parts, else_function($b, @c_args);
            $else_exists = 1;
        }
        else {
            die "as child of case, invalid node name:" . $nodename;
        }
    }
    'CASE ' . ($cond ? $cond . ' ' : '') . join(' ', @parts) . ' END';
}

# private
sub when_function {
    my ($b,@args) = @_;
    if (scalar(@args) != 2) { die "(when (exp) (then_value))"; }
    'WHEN ' . $b->produce_value($args[0]) . ' THEN ' . $b->produce_value($args[1]);
}
# private
sub else_function {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(else (else_value))"; }
    'ELSE ' . $b->produce_value($args[0]);
}

# table generating functions

sub explode {
}

sub json_tuple {
}

sub parse_url_tuple {
}

1;
