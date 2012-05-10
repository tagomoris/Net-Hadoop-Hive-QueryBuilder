package Net::Hadoop::Hive::QueryBuilder::Functions::Data;

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
#        { type => 'f', name => '', proc => \&foobar },
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

##### TODO from here ######
sub from_unixtime {}
sub unix_timestamp {}
sub to_date {}
sub year {}
sub month {}
sub day {}
sub hour {}
sub minute {}
sub second {}
sub weekofyear {}
sub datediff {}
sub date_add {}
sub date_sub {}
##### TODO over here #####

1;
