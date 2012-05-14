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
);
my $bb = bb(@defset);

subtest 'checkargs_and_build' => sub {
    my $s = \&Net::Hadoop::Hive::QueryBuilder::Functions::String::checkargs_and_build;
    is ($s->($bb, 'xxx', '(xxx description string)', [1], [ss('field'), ss('hey')]), 'xxx(hey)');
};

subtest 'length' => sub {
    is (pp('length')->($bb, [ss('string'), 'foobar']), "length('foobar')");
};
subtest 'reverse' => sub {
    is (pp('reverse')->($bb, [ss('string'), 'foobar']), "reverse('foobar')");
};
subtest 'concat' => sub {
    is (pp('concat')->($bb, [ss('string'), 'foobar'], [ss('string'), '1122']), "concat('foobar', '1122')");
    is (pp('concat')->($bb, [ss('string'), 'foobar'], [ss('string'), '1122'], [ss('string'), 'x']), "concat('foobar', '1122', 'x')");
};
subtest 'concat_ws' => sub {
    is (pp('concat_ws')->($bb, [ss('string'), ','], [ss('string'), 'foobar'], [ss('string'), '1122']),
        "concat_ws(',', 'foobar', '1122')");
    is (pp('concat_ws')->($bb, [ss('string'), ','], [ss('string'), 'foobar'], [ss('string'), '1122'], [ss('string'), 'x']),
        "concat_ws(',', 'foobar', '1122', 'x')");
};
subtest 'substr' => sub {
    is (pp('substr')->($bb, [ss('string'), 'foobar'], [ss('number'), ss('5')]), "substr('foobar', 5)");
    is (pp('substr')->($bb, [ss('string'), 'foobar'], [ss('number'), ss('5')], [ss('number'), ss('3')]), "substr('foobar', 5, 3)");
};
subtest 'upper' => sub {
    is (pp('upper')->($bb, [ss('string'), 'foobar']), "upper('foobar')");
};
subtest 'lower' => sub {
    is (pp('lower')->($bb, [ss('string'), 'foobar']), "lower('foobar')");
};
subtest 'trim' => sub {
    is (pp('trim')->($bb, [ss('string'), 'foobar']), "trim('foobar')");
};
subtest 'ltrim' => sub {
    is (pp('ltrim')->($bb, [ss('string'), 'foobar']), "ltrim('foobar')");
};
subtest 'rtrim' => sub {
    is (pp('rtrim')->($bb, [ss('string'), 'foobar']), "rtrim('foobar')");
};
subtest 'regexp_replace' => sub {
    is (pp('regexp_replace')->($bb, [ss('string'), 'foobar'], [ss('string'), 'bar'], [ss('string'), 'baz']),
        "regexp_replace('foobar', 'bar', 'baz')");
};
subtest 'regexp_extract' => sub {
    is (pp('regexp_extract')->($bb, [ss('string'), 'foobar'], [ss('string'), 'foo(ba)(r|z)'], [ss('number'), ss('2')]),
        "regexp_extract('foobar', 'foo(ba)(r|z)', 2)");
};
subtest 'parse_url' => sub {
    is (pp('parse_url')->($bb, [ss('string'), 'http://tagomor.is/about?t=m'], [ss('string'), 'PATH']),
        "parse_url('http://tagomor.is/about?t=m', 'PATH')");
    is (pp('parse_url')->($bb, [ss('string'), 'http://tagomor.is/about?t=m'], [ss('string'), 'QUERY'], [ss('string'), 't']),
        "parse_url('http://tagomor.is/about?t=m', 'QUERY', 't')");
};
subtest 'get_json_object' => sub {
    is (pp('get_json_object')->($bb, [ss('string'), '{"a1":1000,"b1":"foobar"}'], [ss('string'), 'b1']),
        "get_json_object('{\"a1\":1000,\"b1\":\"foobar\"}', 'b1')");
};
subtest 'space' => sub {
    is (pp('space')->($bb, [ss('number'), ss('10')]), "space(10)");
};
subtest 'repeat' => sub {
    is (pp('repeat')->($bb, [ss('string'), 'foobar'], [ss('number'), ss('10')]), "repeat('foobar', 10)");
};
subtest 'ascii' => sub {
    is (pp('ascii')->($bb, [ss('string'), 'a']), "ascii('a')");
};
subtest 'lpad' => sub {
    is (pp('lpad')->($bb, [ss('string'), 'foobar'], [ss('number'), ss('10')], [ss('string'), ' ']), "lpad('foobar', 10, ' ')");
};
subtest 'rpad' => sub {
    is (pp('rpad')->($bb, [ss('string'), 'foobar'], [ss('number'), ss('10')], [ss('string'), ' ']), "rpad('foobar', 10, ' ')");
};
subtest 'split' => sub {
    is (pp('split')->($bb, [ss('string'), 'foobar bazz'], [ss('string'), ss(' ')]), "split('foobar bazz', ' ')");
};
subtest 'find_in_set' => sub {
    is (1,1);
};
subtest 'locate' => sub {
    is (pp('locate')->($bb, [ss('string'), 'foobar'], [ss('string'), ss('ba')]), "locate('foobar', 'ba')");
    is (pp('locate')->($bb, [ss('string'), 'foobar'], [ss('string'), ss('ba')], [ss('number'), ss('1')]), "locate('foobar', 'ba', 1)");
};
subtest 'str_to_map' => sub {
    is (1,1);
};
subtest 'sentences' => sub {
    is (1,1);
};
subtest 'ngrams' => sub {
    is (1,1);
};
subtest 'context_ngrams' => sub {
    is (1,1);
};
subtest 'in_file' => sub {
    is (1,1);
};

done_testing();
