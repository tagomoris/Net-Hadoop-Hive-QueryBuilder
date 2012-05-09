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

subtest 'equal' => sub {
    is (pp('=')->($bb, [ss('number'), ss('1')], [ss('number'), ss('1')]), '1=1');
    is (pp('=')->($bb, [ss('number'), ss('1')], [ss('string'), ss('1')]), "1='1'");
    is (pp('=')->($bb, [ss('number'), ss('1')], [ss('null')]), '1 IS NULL');
    is (pp('=')->($bb, [ss('field'), ss('c1')], [ss('number'), ss('1')]), 'c1=1');
    is (pp('=')->($bb, [ss('field'), ss('c1')], [ss('null')]), 'c1 IS NULL');

    # TODO equal with functions
};

subtest 'notequal' => sub {
    is (pp('!=')->($bb, [ss('number'), ss('1')], [ss('number'), ss('1')]), '1!=1');
    is (pp('!=')->($bb, [ss('number'), ss('1')], [ss('string'), ss('1')]), "1!='1'");
    is (pp('!=')->($bb, [ss('number'), ss('1')], [ss('null')]), '1 IS NOT NULL');
    is (pp('!=')->($bb, [ss('field'), ss('c1')], [ss('number'), ss('1')]), 'c1!=1');
    is (pp('!=')->($bb, [ss('field'), ss('c1')], [ss('null')]), 'c1 IS NOT NULL');

    # TODO notequal with functions
};

push @defset, (
    {name => '=', proc => pp('='), type => 's'},
    {name => '!=', proc => pp('!='), type => 's'},
);
$bb = bb(@defset);

subtest 'equal_with_sentence' => sub {
    is (pp('=')->($bb, [ss('='), [ss('field'), ss('c1')], [ss('string'), 'hoge pos']], [ss('true')]), "(c1='hoge pos')=TRUE");
    is (pp('=')->($bb, [ss('true')], [ss('='), [ss('field'), ss('c1')], [ss('string'), 'hoge pos']]), "TRUE=(c1='hoge pos')");
    is (pp('=')->($bb, [ss('='), [ss('field'), ss('c1')], [ss('string'), 'hoge pos']], [ss('null')]), "(c1='hoge pos') IS NULL");
};

subtest 'notequal_with_sentence' => sub {
    is (pp('!=')->($bb, [ss('='), [ss('field'), ss('c1')], [ss('string'), 'hoge pos']], [ss('true')]), "(c1='hoge pos')!=TRUE");
    is (pp('!=')->($bb, [ss('true')], [ss('='), [ss('field'), ss('c1')], [ss('string'), 'hoge pos']]), "TRUE!=(c1='hoge pos')");
    is (pp('!=')->($bb, [ss('='), [ss('field'), ss('c1')], [ss('string'), 'hoge pos']], [ss('null')]), "(c1='hoge pos') IS NOT NULL");
};

subtest 'in' => sub {
    is (pp('in')->($bb, [ss('field'), ss('c1')], [ss('string'), 'hoge'], [ss('string'), 'moge']), "c1 IN ('hoge', 'moge')");
    is (pp('in')->($bb, [ss('field'), ss('c1')], [ss('true')], [ss('='), [ss('number'), ss('1')], [ss('number'), ss('1')]]),
        "c1 IN (TRUE, (1=1))");
};

subtest 'not' => sub {
    is (pp('not')->($bb, [ss('field'), ss('c1')]), "NOT c1");
    is (pp('not')->($bb, [ss('='), [ss('field'), ss('c1')], [ss('field'), ss('c2')]]), "NOT (c1=c2)");
};

push @defset, {name => 'not', proc => pp('not'), type => 's'};
$bb = bb(@defset);

subtest 'not_with_sentence' => sub {
    is (pp('not')->($bb, [ss('not'), [ss('true')]]), "NOT (NOT TRUE)");
};

subtest 'and' => sub {
    is (pp('and')->($bb, [ss('field'), ss('c1')], [ss('true')]), "c1 AND TRUE");
    is (pp('and')->($bb, [ss('field'), ss('c1')], [ss('not'), [ss('field'), ss('c2')]]), "c1 AND (NOT c2)");
    is (pp('and')->($bb, [ss('field'), ss('c1')], [ss('field'), ss('c2')], [ss('field'), ss('c3')], [ss('not'), [ss('field'), ss('c4')]]),
        "c1 AND c2 AND c3 AND (NOT c4)");
};

subtest 'or' => sub {
    is (pp('or')->($bb, [ss('field'), ss('c1')], [ss('true')]), "c1 OR TRUE");
    is (pp('or')->($bb, [ss('field'), ss('c1')], [ss('not'), [ss('field'), ss('c2')]]), "c1 OR (NOT c2)");
    is (pp('or')->($bb, [ss('field'), ss('c1')], [ss('field'), ss('c2')], [ss('field'), ss('c3')], [ss('not'), [ss('field'), ss('c4')]]),
        "c1 OR c2 OR c3 OR (NOT c4)");
};

push @defset, (
    {name => 'and', proc => pp('and'), type => 's'},
    {name => 'or', proc => pp('or'), type => 's'},
);
$bb = bb(@defset);

subtest 'map_construct' => sub {
    is (pp('map_construct')->($bb), "map()");
    is (pp('map_construct')->($bb, [ss('string'), 'key1'], [ss('string'), 'val1']), "map('key1', 'val1')");
    is (pp('map_construct')->($bb, [ss('string'), 'key1'], [ss('string'), 'val1'], [ss('string'), 'key2'], [ss('true')]), "map('key1', 'val1', 'key2', TRUE)");
    is (pp('map_construct')->($bb, [ss('string'), 'key1'], [ss('string'), 'val1'], [ss('string'), 'key2'], [ss('='), [ss('number'), ss('1')], [ss('number'), ss('1')]]), "map('key1', 'val1', 'key2', (1=1))");
};

subtest 'array_construct' => sub {
    is (pp('array_construct')->($bb), "array()");
    is (pp('array_construct')->($bb, [ss('string'), 'val1'], [ss('string'), 'val2']), "array('val1', 'val2')");
    is (pp('array_construct')->($bb, [ss('string'), 'val1'], [ss('string'), 'val2'], [ss('string'), 'val3'], [ss('true')]), "array('val1', 'val2', 'val3', TRUE)");
    is (pp('array_construct')->($bb, [ss('string'), 'val1'], [ss('string'), 'val2'], [ss('string'), 'val3'], [ss('='), [ss('number'), ss('1')], [ss('number'), ss('1')]]), "array('val1', 'val2', 'val3', (1=1))");
};

push @defset, (
    {name => 'map_construct', proc => pp('map_construct'), type => 'f'},
    {name => 'array_construct', proc => pp('array_construct'), type => 'f'},
);
$bb = bb(@defset);

subtest 'map_get' => sub {
    is (pp('map_get')->($bb, [ss('field'), ss('h1')], [ss('string'), 'key1']), "h1['key1']");
    is (pp('map_get')->($bb, [ss('map_construct'), [ss('string'), 'key1'], [ss('string'), 'val1'], [ss('string'), 'key2'], [ss('true')]], [ss('string'), 'key2']), "map('key1', 'val1', 'key2', TRUE)['key2']");
};

subtest 'array_get' => sub {
    is (pp('array_get')->($bb, [ss('field'), ss('h1')], [ss('number'), ss('1')]), "h1[1]");
    is (pp('array_get')->($bb, [ss('array_construct'), [ss('string'), 'val1'], [ss('string'), 'val2'], [ss('string'), 'val3'], [ss('true')]], [ss('number'), ss('5')]), "array('val1', 'val2', 'val3', TRUE)[5]");
};

done_testing();
