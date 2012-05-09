use strict;
use warnings;
use utf8;

use Test::More;

use t::Util;

use Net::Hadoop::Hive::QueryBuilder;

subtest 'hoge' => sub {
    ok (1);
    is (1, 1);
};

subtest 'dump' => sub {
    my $query_s = <<EOQ
(query
 (select (field yyyymmdd) (map_get (field agentdata) (string "category")) (count *))
 (from (table access_log))
 (where
  (and
   (= (field service) (string "blog"))
   (or
    (= (field yyyymmdd) (string "20120331"))
    (= (field yyyymmdd) (string "20120401"))
    (= (map_get (field agentdata) (string "category")) (string "smartphone")))))
 (aggregate
  (group (field yyyymmdd) (map_get (field agentdata) (string "category")))
  (order (field yyyymmdd) (desc (count *)))
  (limit 30)))
EOQ
        ;
    my $query_hql = <<EOQ
SELECT yyyymmdd, agentdata['category'] AS f1, COUNT(*) AS f2
FROM access_log
WHERE (service='blog') AND ((yyyymmdd='20120331') OR (yyyymmdd='20120401') OR (agentdata['category']='smartphone'))
GROUP BY yyyymmdd, agentdata['category']
ORDER BY yyyymmdd, f2 DESC
LIMIT 30
EOQ
        ;
    chomp $query_hql;

    my $builder = Net::Hadoop::Hive::QueryBuilder->new();
    is ($builder->dump($query_s), $query_hql);
};

done_testing();
