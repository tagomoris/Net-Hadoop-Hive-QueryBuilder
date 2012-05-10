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
}

# conditional functions

sub if_function {
}

sub coalesce {
}

sub case_function {
    # for when and else, try hard in this function only....
}

# private
sub when_function {
}
# private
sub else_function {
}

# table generating functions

sub explode {
}

sub json_tuple {
}

sub parse_url_tuple {
}

1;
