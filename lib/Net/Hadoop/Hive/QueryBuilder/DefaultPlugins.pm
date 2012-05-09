package Net::Hadoop::Hive::QueryBuilder::DefaultPlugins;

use strict;
use warnings;
use Carp;

our $VERSION = "0.1";

use Try::Tiny;

use Net::Hadoop::Hive::QueryBuilder::Operators;
use Net::Hadoop::Hive::QueryBuilder::Functions;

sub plugins {
    +[
        @{query_structure()},
        @{Net::Hadoop::Hive::QueryBuilder::Operators::builtin_operators()},
        @{Net::Hadoop::Hive::QueryBuilder::Functions::builtin_functions()},
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
        { type => 'g', name => 'select', proc => \&select_statement },
        { type => 'g', name => 'from', proc => \&from },
        { type => 'g', name => 'where', proc => \&where },
        { type => 'g', name => 'aggregate', proc => \&aggregate },
        { type => 'g', name => 'group', proc => \&group },
        { type => 'g', name => 'sort', proc => \&sort },
        { type => 'g', name => 'distribute', proc => \&distribute },
        { type => 'g', name => 'cluster', proc => \&cluster },
        { type => 'g', name => 'order', proc => \&order },
        { type => 'f', name => 'asc', proc => \&asc },
        { type => 'f', name => 'desc', proc => \&desc },
        { type => 'g', name => 'limit', proc => \&limit },
        { type => 'q', name => 'query', proc => \&query },
    ];
}

sub plugin_proc {
    my $name = shift;
    foreach my $p (@{query_structure()}) {
        if ($p->{name} eq $name) {
            return $p->{proc};
        }
    }
    return undef;
};

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
    "'$c'";
}

sub number {
    my ($builder,$num) = @_;
    $num->name;
}

sub table {
    my ($builder,$table_sym) = @_;
    $table_sym->name;
}

sub select_statement {
    my ($builder,@args) = @_;
    my @fields = ();
    my @bare_fields = qw(null true false string number field);
    foreach my $arg (@args) {
        my $name = $builder->node_name($arg);

        if (scalar(grep {$_ eq $name} @bare_fields) > 0) {
            push @fields, $builder->produce($arg);
            next;
        }

        my $f = $builder->produce($arg);
        my $alias = $builder->add_alias($f);
        push @fields, "$f AS $alias";
    }
    'SELECT ' . join(", ", @fields);
}

sub from {
    my ($builder,@args) = @_;
    #TODO: JOIN ....
    if (scalar(@args) > 1) {
        die "now we cannot use join...";
    }
    my $arg = $args[0];
    my $name = $builder->node_name($arg);
    if ($name eq 'table') {
        return 'FROM ' . $builder->produce($arg);
    }
    elsif ($name eq 'query') {
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
    my ($builder,@args) = @_;
    if (scalar(@args) < 1) {
        return '';
    }
    my @aggregate_clauses = qw(group sort distribute cluster order limit);
    my @lines = ();
    foreach my $arg (@args) {
        my $type = $builder->node_type($arg);
        my $name = $builder->node_name($arg);
        unless ($type eq 'g') {
            die "invalid node type under 'aggregate':" . $type;
        }
        if (scalar(grep {$name eq $_} @aggregate_clauses) < 1) {
            die "unknown node name under 'aggregate':" . $name;
        }
        push @lines, $builder->produce($arg);
    }
    join("\n", @lines);
}

sub group {
    my ($builder,@args) = @_;
    if (scalar(@args) < 1) {
        die "blank 'group' is invalid";
    }
    'GROUP BY ' . join(', ', map {$builder->produce($_)} @args);
}

sub sort {
    my ($builder,@args) = @_;
    if (scalar(@args) < 1) {
        die "blank 'sort' is invalid";
    }
    'SORT BY ' . join(', ', map {$builder->produce($_)} @args);
}

sub distribute {
    my ($builder,@args) = @_;
    if (scalar(@args) < 1) {
        die "blank 'distribute' is invalid";
    }
    'DISTRIBUTE BY ' . join(', ', map {$builder->produce($_)} @args);
}

sub cluster {
    my ($builder,@args) = @_;
    if (scalar(@args) < 1) {
        die "blank 'cluster' is invalid";
    }
    'CLUSTER BY ' . join(', ', map {$builder->produce($_)} @args);
}

sub order {
    my ($builder,@args) = @_;
    if (scalar(@args) < 1) {
        die "blank 'order' is invalid";
    }
    'ORDER BY ' . join(', ', map {$builder->produce_or_alias($_)} @args);
}

sub asc {
    my ($builder, $arg) = @_;
    unless ($arg) {
        die "blank 'asc' is invalid";
    }
    $builder->produce_or_alias($arg) . ' ASC';
}

sub desc {
    my ($builder, $arg) = @_;
    unless ($arg) {
        die "blank 'desc' is invalid";
    }
    $builder->produce_or_alias($arg) . ' DESC';
}

sub limit {
    my ($builder, $arg) = @_;
    unless ($arg =~ m!^\d+$!) {
        die "'limit' accepts only one interger";
    }
    "LIMIT $arg";
}

sub query {
    my ($builder, @args) = @_;
    foreach my $args (@args) {
        unless ($builder->node_type($args) eq 'g') {
            die "query accepts only grammer type(g) nodes";
        }
    }
    join("\n", map { $builder->produce($_) } @args);
}

1;
