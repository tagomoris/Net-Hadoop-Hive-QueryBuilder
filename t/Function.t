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

subtest 'cast' => sub { is(1,1); };

subtest 'if' => sub { is(1,1); };

subtest 'coalesce' => sub { is(1,1); };

subtest 'case' => sub { is(1,1); };

subtest 'explode' => sub { is(1,1); };

subtest 'json_tuple' => sub { is(1,1); };

subtest 'parse_url_tuple' => sub { is(1,1); };

done_testing();
