package Net::Hadoop::Hive::QueryBuilder;

use strict;
use warnings;
use Carp;

our $VERSION = "0.1";

sub new {
};

sub bind {
}

sub dump {
}
1;

__END__

=head1 NAME

Net::Hadoop::Hive::QueryBuilder - HiveQL query builder module from S-expression

=head1 SYNOPSIS

  use Net::Hadoop::Hive::QueryBuilder;
  my $query = Net::Hadoop::Hive::QueryBuilder->new($s_expression_structure);
  $query->bind($value1, $value2);
  $query->dump; #=> HiveQL query string

=head1 AUTHOR

TAGOMORI Satoshi E<lt>tagomoris {at} gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
