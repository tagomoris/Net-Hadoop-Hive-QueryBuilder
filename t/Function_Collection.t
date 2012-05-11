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

subtest 'size' => sub {
    is (pp('size')->($bb, [ss('field'), ss('col1')]), "size(col1)");
};
subtest 'map_keys' => sub {
    is (pp('map_keys')->($bb, [ss('field'), ss('col1')]), "map_keys(col1)");
};
subtest 'map_values' => sub {
    is (pp('map_values')->($bb, [ss('field'), ss('col1')]), "map_values(col1)");
};
subtest 'array_contains' => sub {
    is (pp('array_contains')->($bb, [ss('field'), ss('col2')], [ss('string'), 'foobar']), "array_contains(col2, 'foobar')");
};

done_testing();
