use strict;
use warnings;
use utf8;

# use lib 't/lib/';

package t::Util;
use parent 'Exporter';

use Data::SExpression::Symbol;

use Net::Hadoop::Hive::QueryBuilder;
use Net::Hadoop::Hive::QueryBuilder::DefaultPlugins;
use Net::Hadoop::Hive::QueryBuilder::Operators;
use Net::Hadoop::Hive::QueryBuilder::Functions;

our @EXPORT = qw(bb pp ss);

sub bb {
    my @plugins = @_;
    Net::Hadoop::Hive::QueryBuilder->new(plugin_modules => [], plugins => \@plugins);
}

sub pp {
    my $name = shift;
    Net::Hadoop::Hive::QueryBuilder::DefaultPlugins::plugin_proc($name)
          or Net::Hadoop::Hive::QueryBuilder::Operators::plugin_proc($name)
          or Net::Hadoop::Hive::QueryBuilder::Functions::plugin_proc($name)
}

sub ss {
    my $sym_str = shift;
    Data::SExpression::Symbol->new($sym_str);
}

1;
