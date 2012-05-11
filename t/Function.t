use strict;
use warnings;
use utf8;

use Test::More;

use t::Util;

subtest 'hoge' => sub {
    ok (1);
    is (1, 1);
};

my @defset = (
    {name => 'table', proc => pp('table'), type => 'f'},
    {name => 'field', proc => pp('field'), type => 'f'},
    {name => 'string', proc => pp('string'), type => 'f'},
    {name => 'number', proc => pp('number'), type => 'f'},
    {name => 'null', proc => pp('null'), type => 'f'},
    {name => 'true', proc => pp('true'), type => 'f'},
    {name => 'false', proc => pp('false'), type => 'f'},
    {name => '=', proc => pp('='), type => 's'},
);
my $bb = bb(@defset);

subtest 'cast' => sub {
    is (pp('cast')->($bb, [ss('field'), ss('col1')], ss('BIGINT')), "CAST(col1 as BIGINT)");
};

push @defset, {name => 'cast', proc => pp('cast'), type => 'f'};
$bb = bb(@defset);

subtest 'if' => sub {
    is (pp('if')->($bb, [ss('true')], [ss('number'), ss('1')], [ss('number'), ss('0')]), "IF(TRUE, 1, 0)");
    is (pp('if')->($bb, [ss('='), [ss('number'), ss('1')], [ss('cast'), [ss('string'), '1'], ss('INT')]], [ss('true')], [ss('null')]),
        "IF((1 = CAST('1' as INT)), TRUE, NULL)");
};

subtest 'coalesce' => sub {
    is (pp('coalesce')->($bb, [ss('field'), ss('col1')]), "COALESCE(col1)");
    is (pp('coalesce')->($bb, [ss('field'), ss('col1')], [ss('field'), ss('col2')], [ss('string'), 'foobar']),
        "COALESCE(col1, col2, 'foobar')");
};

subtest 'when' => sub {
    is (Net::Hadoop::Hive::QueryBuilder::Functions::when_function($bb, [ss('string'), 'foo'], [ss('string'), 'FOO']),
        "WHEN 'foo' THEN 'FOO'");
    is (Net::Hadoop::Hive::QueryBuilder::Functions::when_function($bb,
                                                                  [ss('='), [ss('field'), ss('col1')], [ss('string'), 'foo']],
                                                                  [ss('string'), 'FOO']),
        "WHEN (col1 = 'foo') THEN 'FOO'");
};

subtest 'else' => sub {
    is (Net::Hadoop::Hive::QueryBuilder::Functions::else_function($bb, [ss('string'), 'unknown']), "ELSE 'unknown'");
};

subtest 'case' => sub {
    is (pp('case')->($bb, [ss('when'), [ss('true')], [ss('true')]]), "CASE WHEN TRUE THEN TRUE END");
    is (pp('case')->($bb,
                     [ss('field'), ss('col1')],
                     [ss('when'), [ss('number'), ss('1')], [ss('string'), 'one']],
                     [ss('when'), [ss('number'), ss('2')], [ss('string'), 'two']],
                     [ss('else'), [ss('string'), 'zero']]),
        "CASE col1 WHEN 1 THEN 'one' WHEN 2 THEN 'two' ELSE 'zero' END");
    is (pp('case')->($bb,
                     [ss('when'), [ss('='), [ss('field'), ss('col1')], [ss('number'), ss('1')]], [ss('string'), 'one']],
                     [ss('when'), [ss('='), [ss('field'), ss('col2')], [ss('number'), ss('2')]], [ss('string'), 'two']],
                     [ss('else'), [ss('string'), 'zero']]),
        "CASE WHEN (col1 = 1) THEN 'one' WHEN (col2 = 2) THEN 'two' ELSE 'zero' END");
};

subtest 'explode' => sub { is(1,1); };

subtest 'json_tuple' => sub { is(1,1); };

subtest 'parse_url_tuple' => sub { is(1,1); };

done_testing();
