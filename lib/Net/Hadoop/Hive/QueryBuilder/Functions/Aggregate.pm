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
}

sub avg {
}

sub min {
}

sub max {
}

sub variance {} #TODO
sub var_samp {} #TODO
sub stddev_pop {} #TODO
sub stddev_samp {} #TODO
sub covar_pop {} #TODO
sub covar_samp {} #TODO
sub corr {} #TODO

sub percentile {
}

sub percentile_approx {
}

sub histogram_numeric {} #TODO

sub collect_set {
}

1;
