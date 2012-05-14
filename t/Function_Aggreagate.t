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

subtest 'sum' => sub {
    is (pp('sum')->($bb, [ss('field'), ss('col1')]), "SUM(col1)");
    is (pp('sum')->($bb, ss('distinct'), [ss('field'), ss('col1')]), "SUM(DISTINCT col1)");
};

subtest 'avg' => sub {
    is (pp('avg')->($bb, [ss('field'), ss('col1')]), "AVG(col1)");
    is (pp('avg')->($bb, ss('distinct'), [ss('field'), ss('col1')]), "AVG(DISTINCT col1)");
};

subtest 'min' => sub {
    is (pp('min')->($bb, [ss('field'), ss('col1')]), "MIN(col1)");
};

subtest 'max' => sub {
    is (pp('max')->($bb, [ss('field'), ss('col1')]), "MAX(col1)");
};

subtest 'var_pop' => sub {
    is (1,1);
};

subtest 'var_samp' => sub {
    is (1,1);
};

subtest 'stddev_pop' => sub {
    is (1,1);
};

subtest 'stddev_samp' => sub {
    is (1,1);
};

subtest 'covar_pop' => sub {
    is (1,1);
};

subtest 'covar_samp' => sub {
    is (1,1);
};

subtest 'corr' => sub {
    is (1,1);
};

push @defset, { type => 'f', name => 'array_construct', proc => pp('array_construct') };
$bb = bb(@defset);

subtest 'percentile' => sub {
    is (pp('percentile')->($bb, [ss('field'), ss('col1')], [ss('number'), ss('0.95')]),
        "PERCENTILE(col1, 0.95)");
    is (pp('percentile')->($bb,
                           [ss('field'), ss('col1')],
                           [ss('array_construct'), [ss('number'), ss('0.90')], [ss('number'), ss('0.95')]]),
        "PERCENTILE(col1, array(0.90, 0.95))");
};

subtest 'percentile_approx' => sub {
    is (pp('percentile_approx')->($bb, [ss('field'), ss('col1')], [ss('number'), ss('0.95')]),
        "PERCENTILE_APPROX(col1, 0.95)");
    is (pp('percentile_approx')->($bb, [ss('field'), ss('col1')], [ss('number'), ss('0.95')], [ss('number'), ss('50000')]),
        "PERCENTILE_APPROX(col1, 0.95, 50000)");
    is (pp('percentile_approx')->($bb,
                                  [ss('field'), ss('col1')],
                                  [ss('array_construct'), [ss('number'), ss('0.90')], [ss('number'), ss('0.95')]]),
        "PERCENTILE_APPROX(col1, array(0.90, 0.95))");
    is (pp('percentile_approx')->($bb,
                                  [ss('field'), ss('col1')],
                                  [ss('array_construct'), [ss('number'), ss('0.90')], [ss('number'), ss('0.95')]],
                                  [ss('number'), ss('3000')]),
        "PERCENTILE_APPROX(col1, array(0.90, 0.95), 3000)");
};

subtest 'histogram_numeric' => sub {
    is (1,1);
};

subtest 'collect_set' => sub {
    is (pp('collect_set')->($bb, [ss('field'), ss('col1')]), "COLLECT_SET(col1)");
};

done_testing();
