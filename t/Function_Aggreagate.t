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

subtest 'count' => sub {
    is (pp('count')->($bb, ss('*')), "COUNT(*)");
    is (pp('count')->($bb, [ss('field'), ss('col1')]), "COUNT(col1)");
    is (pp('count')->($bb, ss('distinct'), [ss('field'), ss('col1')], [ss('field'), ss('col2')]), "COUNT(DISTINCT col1, col2)");
};

done_testing();
