package Net::Hadoop::Hive::QueryBuilder::Functions::Mathematical;

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
        { type => 'f', name => 'round', proc => \&round },
        { type => 'f', name => 'floor', proc => \&floor },
        { type => 'f', name => 'ceil', proc => \&ceil },
        { type => 'f', name => 'rand', proc => \&rand_function },
        { type => 'f', name => 'exp', proc => \&exp_function },
        { type => 'f', name => 'ln', proc => \&ln },
        { type => 'f', name => 'log10', proc => \&log10 },
        { type => 'f', name => 'log2', proc => \&log2 },
        { type => 'f', name => 'log', proc => \&log_function },
        { type => 'f', name => 'power', proc => \&power },
        { type => 'f', name => 'sqrt', proc => \&sqrt_function },

#        { type => 'f', name => 'bin', proc => \&bin },
#        { type => 'f', name => 'hex', proc => \&hex_function },
#        { type => 'f', name => 'unhex', proc => \&unhex_function },
#        { type => 'f', name => 'conv', proc => \&conv },

        { type => 'f', name => 'abs', proc => \&abs_function },
        { type => 'f', name => 'pmod', proc => \&pmod },

#        { type => 'f', name => 'sin', proc => \&sin_function },
#        { type => 'f', name => 'asin', proc => \&asin_function },
#        { type => 'f', name => 'cos', proc => \&cos_function },
#        { type => 'f', name => 'acos', proc => \&acos_function },
#        { type => 'f', name => 'tan', proc => \&tan_function },
#        { type => 'f', name => 'atan', proc => \&atan_function },

        { type => 'f', name => 'degrees', proc => \&degrees },
        { type => 'f', name => 'radians', proc => \&radians },
        { type => 'f', name => 'positive', proc => \&positive },
        { type => 'f', name => 'negative', proc => \&negative },
        { type => 'f', name => 'sign', proc => \&sign },
        { type => 'f', name => 'e', proc => \&e_function },
        { type => 'f', name => 'pi', proc => \&pi_function },
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

sub round {
    my ($b,@args) = @_;
    if (scalar(@args) != 1 and scalar(@args) != 2) { die "(round (number a)) or (round (number a) (number d))"; }
    'round(' . join(', ', map { $b->produce_value($_) } @args) . ')';
}
sub floor {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(floor (number a))"; }
    'floor(' . $b->produce_value($args[0]) . ')';
}
sub ceil {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(ceil (number a))"; }
    'ceil(' . $b->produce_value($args[0]) . ')';
}
sub rand_function {
    my ($b,@args) = @_;
    if (scalar(@args) > 1) { die "(rand) or (rand (number seed))"; }
    return 'rand(' . $b->produce_value($args[0]) . ')' if @args;
    'rand()';
}
sub exp_function {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(exp (number a))"; }
    'exp(' . $b->produce_value($args[0]) . ')';
}
sub ln {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(ln (number a))"; }
    'ln(' . $b->produce_value($args[0]) . ')';
}
sub log10 {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(log10 (number a))"; }
    'log10(' . $b->produce_value($args[0]) . ')';
}
sub log2 {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(log2 (number a))"; }
    'log2(' . $b->produce_value($args[0]) . ')';
}
sub log_function {
    my ($b,@args) = @_;
    if (scalar(@args) != 2) { die "(log (number base) (number a))"; }
    'log(' . $b->produce_value($args[0]) . ', ' . $b->produce_value($args[1]) . ')';
}
sub power {
    my ($b,@args) = @_;
    if (scalar(@args) != 2) { die "(pow (number a) (number p))"; }
    'power(' . $b->produce_value($args[0]) . ', ' . $b->produce_value($args[1]) . ')';
}
sub sqrt_function {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(sqrt (number a))"; }
    'sqrt(' . $b->produce_value($args[0]) . ')';
}
sub bin {} #TODO
sub hex_function {} #TODO
sub unhex_function {} #TODO
sub conv {} #TODO
sub abs_function {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(abs (number a))"; }
    'abs(' . $b->produce_value($args[0]) . ')';
}
sub pmod {
    my ($b,@args) = @_;
    if (scalar(@args) != 2) { die "(pmod (number a) (number b))"; }
    'pmod(' . $b->produce_value($args[0]) . ', ' . $b->produce_value($args[1]) . ')';
}

sub sin_function {} #TODO
sub asin_function {} #TODO
sub cos_function {} #TODO
sub acos_function {} #TODO
sub tan_function {} #TODO
sub atan_function {} #TODO

sub degrees {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(degrees (number a))"; }
    "degrees(" . $b->produce_value($args[0]) . ')';
}
sub radians {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(radians (number a))"; }
    'radians(' . $b->produce_value($args[0]) . ')';
}
sub positive {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(positive (number a))"; }
    'positive(' . $b->produce_value($args[0]) . ')';
}
sub negative {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(negative (number a))"; }
    'negative(' . $b->produce_value($args[0]) . ')';
}
sub sign {
    my ($b,@args) = @_;
    if (scalar(@args) != 1) { die "(sign (number a))"; }
    'sign(' . $b->produce_value($args[0]) . ')';
}
sub e_function {
    my ($b,@args) = @_;
    if (scalar(@args) > 0) { die "(e)"; }
    'e()';
}
sub pi_function {
    my ($b,@args) = @_;
    if (scalar(@args) > 0) { die "(pi)"; }
    'pi()';
}

1;
