use strict;
use warnings;
use utf8;

use Test::More;

use t::Util;

subtest 'hoge' => sub {
    ok (1);
    is (1, 1);
};

my $bb = bb(
    {name => 'table', proc => pp('table'), type => 'f'},
    {name => 'field', proc => pp('field'), type => 'f'},
    {name => 'string', proc => pp('string'), type => 'f'},
    {name => 'number', proc => pp('number'), type => 'f'},
    {name => 'null', proc => pp('null'), type => 'f'},
    {name => 'true', proc => pp('true'), type => 'f'},
    {name => 'false', proc => pp('false'), type => 'f'},
);

subtest 'equal' => sub {
    is (pp('=')->($bb, [ss('number'), ss('1')], [ss('number'), ss('1')]), '1=1');
    is (pp('=')->($bb, [ss('number'), ss('1')], [ss('string'), ss('1')]), "1='1'");
    is (pp('=')->($bb, [ss('number'), ss('1')], [ss('null')]), '1 IS NULL');
    is (pp('=')->($bb, [ss('field'), ss('c1')], [ss('number'), ss('1')]), 'c1=1');
    is (pp('=')->($bb, [ss('field'), ss('c1')], [ss('null')]), 'c1 IS NULL');

    # TODO equal with functions
};

$bb = bb(
    {name => 'table', proc => pp('table'), type => 'f'},
    {name => 'field', proc => pp('field'), type => 'f'},
    {name => 'string', proc => pp('string'), type => 'f'},
    {name => 'number', proc => pp('number'), type => 'f'},
    {name => 'null', proc => pp('null'), type => 'f'},
    {name => 'true', proc => pp('true'), type => 'f'},
    {name => 'false', proc => pp('false'), type => 'f'},
    {name => '=', proc => pp('='), type => 's'},
);

subtest 'equal_with_sentence' => sub {
    is (pp('=')->($bb, [ss('='), [ss('field'), ss('c1')], [ss('string'), 'hoge pos']], [ss('true')]), "(c1='hoge pos')=TRUE");
    is (pp('=')->($bb, [ss('='), [ss('field'), ss('c1')], [ss('string'), 'hoge pos']], [ss('null')]), "(c1='hoge pos') IS NULL");
};


done_testing();
