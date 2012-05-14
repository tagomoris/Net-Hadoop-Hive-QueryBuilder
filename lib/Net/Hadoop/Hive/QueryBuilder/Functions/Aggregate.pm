package Net::Hadoop::Hive::QueryBuilder::Functions::Aggregate;

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
        { type => 'f', name => 'count', proc => \&count },
        { type => 'f', name => 'sum', proc => \&sum },
        { type => 'f', name => 'avg', proc => \&avg },
        { type => 'f', name => 'min', proc => \&min },
        { type => 'f', name => 'max', proc => \&max },

        # { type => 'f', name => 'variance', proc => \&variance },
        # { type => 'f', name => 'var_samp', proc => \&var_samp },
        # { type => 'f', name => 'stddev_pop', proc => \&stddev_pop },
        # { type => 'f', name => 'stddev_samp', proc => \&stddev_samp },
        # { type => 'f', name => 'covar_pop', proc => \&covar_pop },
        # { type => 'f', name => 'covar_samp', proc => \&covar_samp },
        # { type => 'f', name => 'corr', proc => \&corr },

        { type => 'f', name => 'percentile', proc => \&percentile },
        { type => 'f', name => 'percentile_approx', proc => \&percentile_approx },

#        { type => 'f', name => 'histogram_numeric', proc => \&histogram_numeric },

        { type => 'f', name => 'collect_set', proc => \&collect_set },
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

sub count {
    # (count *)
    # (count (expr))
    # (count distinct (expr) (expr) ...)
    my ($builder,@args) = @_;
    if (scalar(@args) < 2) {
        my $arg = shift @args;
        if (ref($arg) eq 'Data::SExpression::Symbol') {
            die "invalid bareword for count argument" . $arg->name unless $arg->name eq '*';
            return 'COUNT(*)';
        }
        return 'COUNT(' . $builder->produce_value($arg) . ')';
    }
    # len(args) >= 2
    my ($distinct, @lest) = @args;
    unless (ref($distinct) eq 'Data::SExpression::Symbol' and $distinct->name eq 'distinct') {
        die "count with 2 or more arguments allowed only with 'distinct'";
    }
    unless (scalar(@lest) > 0) {
        die "count distinct needs 1 or more arguments";
    }
    'COUNT(DISTINCT ' . join(', ', map { $builder->produce_value($_) } @lest) . ')';
}

sub sum {
    # (sum (field col1))
    # (sum distinct (field col1))
    my ($b,@args) = @_;
    if (scalar(@args) < 1 or scalar(@args) > 2) {
        die "sum nees 1 column or 2 arguments ('distinct' + col)";
    }
    if (scalar(@args) == 1) {
        return 'SUM(' . $b->produce_value($args[0]) . ')';
    }
    my $distinct = shift @args;
    unless (ref($distinct) eq 'Data::SExpression::Symbol' and $distinct->name eq 'distinct') {
        die "sum with 2 arguments needs 'distinct' for 1st argument";
    }
    'SUM(DISTINCT ' . $b->produce_value($args[0]) . ')';
}

sub avg {
    # (avg (field col1))
    # (avg distinct (field col1))
    my ($b,@args) = @_;
    if (scalar(@args) < 1 or scalar(@args) > 2) {
        die "avg nees 1 column or 2 arguments ('distinct' + col)";
    }
    if (scalar(@args) == 1) {
        return 'AVG(' . $b->produce_value($args[0]) . ')';
    }
    my $distinct = shift @args;
    unless (ref($distinct) eq 'Data::SExpression::Symbol' and $distinct->name eq 'distinct') {
        die "avg with 2 arguments needs 'distinct' for 1st argument";
    }
    'AVG(DISTINCT ' . $b->produce_value($args[0]) . ')';
}

sub min {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(min (field col1))"; }
    'MIN(' . $b->produce_value($args[0]) . ')';
}

sub max {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(max (field col1))"; }
    'MAX(' . $b->produce_value($args[0]) . ')';
}

sub variance {} #TODO
sub var_samp {} #TODO
sub stddev_pop {} #TODO
sub stddev_samp {} #TODO
sub covar_pop {} #TODO
sub covar_samp {} #TODO
sub corr {} #TODO

sub percentile {
    my ($b,@args) = @_;
    if (scalar(@args) != 2) {
        die "(percentile (field col1) (number 0.95)) or (percentile (field col1) (array 0.9 0.91 0.92 ...))";
    }
    'PERCENTILE(' . $b->produce_value($args[0]) . ', ' . $b->produce_value($args[1]) . ')';
}

sub percentile_approx {
    my ($b,@args) = @_;
    if (scalar(@args) != 2 and scalar(@args) != 3) {
        die "(percentile_approx (field col1) (p) [(number B)])";
    }
    'PERCENTILE_APPROX(' . join(', ', map { $b->produce_value($_) } @args) . ')';
}

sub histogram_numeric {} #TODO

sub collect_set {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(collect_set (field col))"; }
    'COLLECT_SET(' . $b->produce_value($args[0]) . ')';
}

1;
