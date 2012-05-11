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

subtest 'round' => sub {
    is (pp('round')->($bb, [ss('number'), ss('1')]), "round(1)");
    is (pp('round')->($bb, [ss('number'), ss('1')], [ss('number'), ss('10')]), "round(1, 10)");
};

subtest 'floor' => sub {
    is (pp('floor')->($bb, [ss('number'), ss('1.5')]), "floor(1.5)");
};

subtest 'ceil' => sub {
    is (pp('ceil')->($bb, [ss('number'), ss('3.1')]), "ceil(3.1)");
};

subtest 'rand' => sub {
    is (pp('rand')->($bb), "rand()");
    is (pp('rand')->($bb, [ss('number'), ss('1000')]), "rand(1000)");
};

subtest 'exp' => sub {
    is (pp('exp')->($bb, [ss('number'), ss('1.0')]), "exp(1.0)");
};

subtest 'ln' => sub {
    is (pp('ln')->($bb, [ss('number'), ss('5.0')]), "ln(5.0)");
};

subtest 'log10' => sub {
    is (pp('log10')->($bb, [ss('number'), ss('100')]), "log10(100)");
};

subtest 'log2' => sub {
    is (pp('log2')->($bb, [ss('number'), ss('4.8')]), "log2(4.8)");
};

subtest 'log' => sub {
    is (pp('log')->($bb, [ss('number'), ss('16')], [ss('number'), ss('4.0')]), "log(16, 4.0)");
};

subtest 'power' => sub {
    is (pp('power')->($bb, [ss('number'), ss('5.0')], [ss('number'), ss('2')]), "power(5.0, 2)");
};

subtest 'sqrt' => sub {
    is (pp('sqrt')->($bb, [ss('number'), ss('4')]), "sqrt(4)");
};

subtest 'abs' => sub {
    is (pp('abs')->($bb, [ss('number'), ss('-4')]), "abs(-4)");
};

subtest 'pmod' => sub {
    is (pp('pmod')->($bb, [ss('number'), ss('-4')], [ss('number'), ss('2')]), "pmod(-4, 2)");
};

subtest 'degrees' => sub {
    is (pp('degrees')->($bb, [ss('number'), ss('3.14')]), "degrees(3.14)");
};

subtest 'radians' => sub {
    is (pp('radians')->($bb, [ss('number'), ss('180.0')]), "radians(180.0)");
};

subtest 'positive' => sub {
    is (pp('positive')->($bb, [ss('number'), ss('-5')]), "positive(-5)");
};

subtest 'negative' => sub {
    is (pp('negative')->($bb, [ss('number'), ss('3')]), "negative(3)");
};

subtest 'sign' => sub {
    is (pp('sign')->($bb, [ss('number'), ss('-5')]), "sign(-5)");
};

subtest 'e' => sub {
    is (pp('e')->($bb), "e()");
};

subtest 'pi' => sub {
    is (pp('pi')->($bb), "pi()");
};

done_testing();
