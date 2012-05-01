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

my $bb = bb(
    # simple builder instance with field and value set
    {name => 'table', proc => pp('table'), type => 'f'},
    {name => 'field', proc => pp('field'), type => 'f'},
    {name => 'string', proc => pp('string'), type => 'f'},
    {name => 'number', proc => pp('number'), type => 'f'},
    {name => 'null', proc => pp('null'), type => 'f'},
    {name => 'true', proc => pp('true'), type => 'f'},
    {name => 'false', proc => pp('false'), type => 'f'},
    # {name => 'count', proc => pp('count'), type => 'f'},
);

subtest 'select' => sub {
    is (pp('select')->($bb, [ss('field'), ss('hoge')], [ss('field'), ss('moge')]), 'SELECT hoge, moge');
    is (pp('select')->($bb, [ss('string'), ss('hoge')], [ss('string'), ss('moge')]), "SELECT 'hoge', 'moge'");
    is (pp('select')->($bb, [ss('number'), ss('100')], [ss('null')]), "SELECT 100, NULL");
    is (pp('select')->($bb, [ss('true')], [ss('false')]), "SELECT TRUE, FALSE");
};

subtest 'select_aliased_fields' => sub {
    #TODO aliased fields tests
    is (1, 1);
};

subtest 'from' => sub {
    is (pp('from')->($bb, [ss('table'), ss('hoge_tbl')]), 'FROM hoge_tbl');
};

subtest 'from_subquery' => sub {
    # TODO
    is (1, 1);
};

subtest 'from_join' => sub {
    # TODO
    is (1, 1);
};

subtest 'where' => sub {
    #is (pp('where')->($bb, [ss('='), [ss('field'), ss('hoge')], [ss('null')]]), 'WHERE hoge IS NULL');
    #is (pp('where')->($bb, [ss('='), [ss('field'), ss('hoge')], [ss('number'), ss('100')]]), 'WHERE hoge=100');
    #is (pp('where')->($bb, [ss('='), [ss('field'), ss('hoge')], [ss('string'), ss('xxx')]]), "WHERE hoge='xxx'");

    #############



    # TODO after operators and functions
    is (1, 1);
};

subtest 'group' => sub {
    is (pp('group')->($bb, [ss('field'), ss('date')]), 'GROUP BY date');
    is (pp('group')->($bb, [ss('field'), ss('date')], [ss('field'), ss('status')]), 'GROUP BY date, status');
    # TODO group by with functions
};

subtest 'distribute' => sub {
    is (pp('distribute')->($bb, [ss('field'), ss('date')]), 'DISTRIBUTE BY date');
    is (pp('distribute')->($bb, [ss('field'), ss('date')], [ss('field'), ss('status')]), 'DISTRIBUTE BY date, status');
    # TODO distribute by with functions
};

subtest 'cluster' => sub {
    is (pp('cluster')->($bb, [ss('field'), ss('date')]), 'CLUSTER BY date');
    is (pp('cluster')->($bb, [ss('field'), ss('date')], [ss('field'), ss('status')]), 'CLUSTER BY date, status');
    # TODO cluster by with functions
};

subtest 'asc' => sub {
    is (pp('asc')->($bb, [ss('field'), ss('c1')]), 'c1 ASC');
    is (pp('asc')->($bb, [ss('field'), ss('hoge')]), 'hoge ASC');
    # TODO asc with functions
};

subtest 'desc' => sub {
    is (pp('desc')->($bb, [ss('field'), ss('c1')]), 'c1 DESC');
    is (pp('desc')->($bb, [ss('field'), ss('hoge')]), 'hoge DESC');
    # TODO desc with functions
};

$bb = bb(
    # simple builder instance with field and value set
    {name => 'table', proc => pp('table'), type => 'f'},
    {name => 'field', proc => pp('field'), type => 'f'},
    {name => 'string', proc => pp('string'), type => 'f'},
    {name => 'number', proc => pp('number'), type => 'f'},
    {name => 'null', proc => pp('null'), type => 'f'},
    {name => 'true', proc => pp('true'), type => 'f'},
    {name => 'false', proc => pp('false'), type => 'f'},
    {name => 'asc', proc => pp('asc'), type => 'f'},
    {name => 'desc', proc => pp('desc'), type => 'f'},
);

subtest 'sort' => sub {
    is (pp('sort')->($bb, [ss('field'), ss('date')]), 'SORT BY date');
    is (pp('sort')->($bb, [ss('field'), ss('date')], [ss('field'), ss('status')]), 'SORT BY date, status');
    is (pp('sort')->($bb, [ss('desc'), [ss('field'), ss('date')]], [ss('field'), ss('status')]), 'SORT BY date DESC, status');
    is (pp('sort')->($bb, [ss('field'), ss('date')], [ss('desc'), [ss('field'), ss('status')]]), 'SORT BY date, status DESC');
    # TODO sort by with functions
};

subtest 'order' => sub {
    is (pp('order')->($bb, [ss('field'), ss('date')]), 'ORDER BY date');
    is (pp('order')->($bb, [ss('field'), ss('date')], [ss('field'), ss('status')]), 'ORDER BY date, status');
    is (pp('order')->($bb, [ss('desc'), [ss('field'), ss('date')]], [ss('field'), ss('status')]), 'ORDER BY date DESC, status');
    is (pp('order')->($bb, [ss('field'), ss('date')], [ss('desc'), [ss('field'), ss('status')]]), 'ORDER BY date, status DESC');
    # TODO order by with aliases
};

subtest 'limit' => sub {
    is (pp('limit')->($bb, ss('100')), 'LIMIT 100');
};

$bb = bb(
    # simple builder instance with field and value set
    {name => 'table', proc => pp('table'), type => 'f'},
    {name => 'field', proc => pp('field'), type => 'f'},
    {name => 'string', proc => pp('string'), type => 'f'},
    {name => 'number', proc => pp('number'), type => 'f'},
    {name => 'null', proc => pp('null'), type => 'f'},
    {name => 'true', proc => pp('true'), type => 'f'},
    {name => 'false', proc => pp('false'), type => 'f'},
    {name => 'asc', proc => pp('asc'), type => 'f'},
    {name => 'desc', proc => pp('desc'), type => 'f'},
    {name => 'group', proc => pp('group'), type => 'g'},
    {name => 'sort', proc => pp('sort'), type => 'g'},
    {name => 'distribute', proc => pp('distribute'), type => 'g'},
    {name => 'cluster', proc => pp('cluster'), type => 'g'},
    {name => 'order', proc => pp('order'), type => 'g'},
    {name => 'limit', proc => pp('limit'), type => 'g'},
);

subtest 'aggregate' => sub {
    is (pp('aggregate')->($bb, [ss('group'), [ss('field'), ss('c1')]]), 'GROUP BY c1');
    is (pp('aggregate')->($bb, [ss('sort'), [ss('field'), ss('c1')]]), 'SORT BY c1');
    is (pp('aggregate')->($bb, [ss('distribute'), [ss('field'), ss('c1')]]), 'DISTRIBUTE BY c1');
    is (pp('aggregate')->($bb, [ss('cluster'), [ss('field'), ss('c1')]]), 'CLUSTER BY c1');
    is (pp('aggregate')->($bb, [ss('order'), [ss('desc'), [ss('field'), ss('c1')]]]), 'ORDER BY c1 DESC');
    is (pp('aggregate')->($bb, [ss('limit'), ss('100')]), 'LIMIT 100');

    is (pp('aggregate')->($bb,
                          [ss('group'), [ss('field'), ss('c1')]],
                          [ss('order'), [ss('desc'), [ss('field'), ss('c1')]]],
                          [ss('limit'), ss('100')]),
        "GROUP BY c1\nORDER BY c1 DESC\nLIMIT 100");
};

subtest 'query' => sub {
    # TODO
    is (1, 1);
};

done_testing();
