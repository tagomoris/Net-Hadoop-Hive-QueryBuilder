package Net::Hadoop::Hive::QueryBuilder::DefaultPlugins;

use strict;
use warnings;
use Carp;

our $VERSION = "0.1";

use Try::Tiny;

sub plugins {
    +[
        {name => '', proc => \&},
        {name => '', proc => \&},
        {name => '', proc => \&},
        {name => '', proc => \&},
    ];
}

# type
# f: formula
# s: sentence
# g: grammer (hql reserved word)
# q: query

sub query_structure {
    +[
        { type => 'f', name => 'true', proc => \&true },
        { type => 'f', name => 'false', proc => \&false },
        { type => 'f', name => 'null', proc => \&null },
        { type => 'f', name => 'field', proc => \&field },
        { type => 'f', name => 'string', proc => \&string },
        { type => 'f', name => 'number', proc => \&number },
        { type => 'f', name => 'table', proc => \&table },
        { type => 's', name => 'fields', proc => \&fields },
        { type => 'g', name => 'from', proc => \&from },
        { type => 'g', name => 'where', proc => \&where },
        { type => 'g', name => 'aggregate', proc => \&aggregate },
        { type => 'g', name => 'group', proc => \&group },
        { type => 'g', name => 'order', proc => \&order },
        { type => 'g', name => 'limit', proc => \&limit },
        { type => 'q', name => 'query', proc => \&query },
    ];
}

sub true { 'TRUE'; }

sub false { 'FALSE'; }

sub null { 'NULL'; }

sub field {
    my ($builder, $field) = @_;
    $field->name;
}

sub string {
    my ($builder,$str) = @_;
    my $c = "$str";
    $c =~ s/\\/\\\\/g;
    $c =~ s/'/\\'/g;
    $c;
}

sub number {
    my ($builder,$num) = @_;
    $num->name;
}

sub table {
    my ($builder,$table_sym) = @_;
    $table_sym->name;
}

sub fields {
    my ($builder,@args) = @_;
    my @fields = ();
    foreach my $arg (@args) {
        my $name = $arg->name;

        if ($name eq 'null' or $name eq 'string' or $name eq 'number' or $name eq 'field') {
            push @fields, $builder->produce($arg);
            next;
        }

        my $f = $builder->produce($arg);
        my $alias = $builder->add_alias($f);
        push @fields, "$f AS $alias";
    }
    join(", ", @fields);
}

sub from {
    my ($builder,@args) = @_;
    #TODO: JOIN ....
    if (scalar(@args) > 1) {
        die "now we cannot use join...";
    }
    my $arg = $args[0];
    if ($arg->[0]->name eq 'table') {
        return 'FROM ' . $builder->produce($arg);
    }
    elsif ($arg->[0]->name eq 'query') {
        my @lines = ('FROM (');
        my $subquery = $builder->produce($arg);
        my $alias = $builder->add_table_alias($subquery);
        push @lines, map { '  ' . $_ } split(/\n/, $subquery);
        push @lines, ') ' . $alias;
        return join("\n", @lines);
    }
    else {
        die "unknown from type";
    }
}

sub where {
    my ($builder,@args) = @_;
    if (scalar(@args) > 1) {
        die "where accepts only 1 formula or sentence";
    }
    my $arg = $args[0];

    my $t = $builder->node_type($arg);
    unless ($t eq 'f' or $t eq 's') {
        die "invalid node type: " . $t;
    }

    if ($builder->node_type($arg) eq 'f') {
        return 'WHERE ' . $builder->produce($arg);
    }
    # sentence
    my @lines = split(/\n/, $builder->produce($arg));
    my $head = 'WHERE ' . (shift @lines);
    join("\n", $head, @lines);
}

sub aggregate {
}

sub group {
}

sub order {
}

sub limit {
}

sub query {
}

# operators

sub builtin_operators {
    +[
        {name => '', proc => \&},
        {name => '', proc => \&},
        {name => '', proc => \&},
        {name => '', proc => \&},
    ];
}

sub in_operator {
}

sub and_operator {
}

sub or_operator {
}

sub equal_operator {
}

sub plus_operator {
}

sub minus_operator {
}

# functions

sub builtin_functions {
    +[
        {name => '', proc => \&},
        {name => '', proc => \&},
        {name => '', proc => \&},
        {name => '', proc => \&},
    ];
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
