use strict;
use warnings;
use utf8;

use Test::More;

use Data::SExpression::Symbol;

use Net::Hadoop::Hive::QueryBuilder;
use Net::Hadoop::Hive::QueryBuilder::DefaultPlugins;

my $p = 'Net::Hadoop::Hive::QueryBuilder::DefaultPlugins';

sub bb {
    my @plugins = @_;
    Net::Hadoop::Hive::QueryBuilder->new(plugin_modules => [], plugins => \@plugins);
}

sub pp {
    my $name = shift;
    Net::Hadoop::Hive::QueryBuilder::DefaultPlugins::plugin_proc($name);
}

sub ss {
    my $sym_str = shift;
    Data::SExpression::Symbol->new($sym_str);
}

subtest 'hoge' => sub {
    ok (1);
    is (1, 1);
};

subtest 'true, false, null' => sub {
    is (pp('true')->(bb), 'TRUE');
    is (pp('false')->(bb), 'FALSE');
    is (pp('null')->(bb), 'NULL');
};

subtest 'field, string, number, table' => sub {
    is (pp('field')->(bb, ss('hoge')), 'hoge');
    is (pp('string')->(bb, ss('hoge')), "'hoge'");
    is (pp('number')->(bb, ss('10')), '10');
    is (pp('number')->(bb, ss('22.3')), '22.3');
    is (pp('table')->(bb, ss('hoge_tbl')), 'hoge_tbl');
};


done_testing();
