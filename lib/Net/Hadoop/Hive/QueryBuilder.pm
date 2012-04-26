package Net::Hadoop::Hive::QueryBuilder;

use strict;
use warnings;
use Carp;

our $VERSION = "0.1";

use Try::Tiny;
use Data::SExpression;

use Net::Hadoop::Hive::QueryBuilder::DefaultPlugins;

# (query
#  (fields (field yyyymmdd) (hash (parse_agent (field agent)) (string "category")) (count (field *)))
#  (from (table access_log))
#  (where
#   (and
#    (= (field service) (string "blog"))
#    (or
#     (= (field yyyymmdd) (string "20120331"))
#     (= (field yyyymmdd) (string "20120401"))
#     (= (hash (parse_agent (field agent)) (string "category")) (string "smartphone")))))
#  (aggregate
#   (group (fields (field yyyymmdd) (hash (parse_agent (field agent)) (string "category"))))
#   (order (fields (asc (field yyyymmdd)) (desc (count (field *)))))
#   (limit 30)))
# ;; (count (field *))
# ;; (count (field hoge))
# ;; (count (is_smartphone(parse_agent(agent))))
# ;; (count (if (= (field status) (number 500)) (number 1) (null)))

sub new {
    my ($this, $s_expression_string, %opts) = @_;
    my $ds = Data::SExpression->new({use_symbol_class => 1});
    my $plugins = $opts{plugins} || [];
    my $plugin_map = {};
    foreach my $p (@$plugins) {
        $plugin_map{$p->{name}} = $p;
    }
    return bless +{
        parser => $ds,
        expression => $s_expression_string,
        plugin_map => $plugin_map,
        aliases => [],
        alias_map => {},
        table_aliases => [],
        table_aliase_map => {},
    }, $this;
}

sub add_plugin {
    my ($self, $plugin) = @_;
    $self->{plugin_map}->{$plugin->{name}} = $plugin;
}

sub error {
    (shift)->{error};
}

sub proc {
    my ($self, $name) = @_;
    $self->{plugin_map}->{$name}->{proc};
}

sub type {
    my ($self, $name) = @_;
    $self->{plugin_map}->{$name}->{type};
}

sub node_type {
    my ($self, $tree) = @_;
    my $name = $tree->[0]->name;
    $self->type($name);
}

sub produce {
    my ($self, $tree) = @_;
    my $car = shift @$tree; # tree is cdr
    unless (ref($car) and ref($car) eq 'Data::SExpression::Symbol') {
        die "all of 'car' must be symbol";
    }
    $self->proc($sym->name)->($self, @$tree);
}

sub add_alias {
    my ($self, $exp) = @_;
    my $size = scalar(@{$self->{aliases}});
    my $as = "f" . ($size + 1);
    push @{$self->{aliases}}, $as;
    $self->{alias_map}->{$exp} = $as;
    $as;
}

sub alias {
    my ($self, $exp) = @_;
    $self->{alias_map}->{$exp};
}

sub add_table_alias {
    my ($self, $exp) = @_;
    my $size = scalar(@{$self->{aliases}});
    my $as = "x" . ($size + 1);
    push @{$self->{table_aliases}}, $as;
    $self->{table_alias_map}->{$exp} = $as;
    $as;
}

sub table_alias {
    my ($self, $exp) = @_;
    $self->{table_alias_map}->{$exp};
}

sub dump {
    my $self = shift;
    my $q;
    try {
        $q = $self->{parser}->read($self->{expression});
    } catch {
        $q = undef;
        $self->{error} = "S-expression parse error";
    };
    return undef unless $q;

    my $toplevel = $q->[0];
    if ($toplevel->name ne 'query') {
        $self->{error} = "toplevel is not 'query'";
        return undef;
    }
    my $result;
    try {
        $result = $self->produce($q);
    } catch {
        $self->{error} = $_;
        $result = undef;
    };
    $result;
}

1;

__END__

=head1 NAME

Net::Hadoop::Hive::QueryBuilder - HiveQL query builder module from S-expression

=head1 SYNOPSIS

  use Net::Hadoop::Hive::QueryBuilder;
  my $query = Net::Hadoop::Hive::QueryBuilder->new($s_expression_string);
  $query->dump; #=> HiveQL query string or undef (error)

=head1 AUTHOR

TAGOMORI Satoshi E<lt>tagomoris {at} gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
