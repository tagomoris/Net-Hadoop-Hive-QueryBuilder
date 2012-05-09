package Net::Hadoop::Hive::QueryBuilder;

use strict;
use warnings;
use Carp;

our $VERSION = "0.1";

use Try::Tiny;
use Data::SExpression;

use Net::Hadoop::Hive::QueryBuilder::DefaultPlugins;

# (query
#  (select (field yyyymmdd) (map_get (parse_agent (field agent)) (string "category")) (count *))
#  (from (table access_log))
#  (where
#   (and
#    (= (field service) (string "blog"))
#    (or
#     (= (field yyyymmdd) (string "20120331"))
#     (= (field yyyymmdd) (string "20120401"))
#     (= (hash (parse_agent (field agent)) (string "category")) (string "smartphone")))))
#  (aggregate
#   (group (field yyyymmdd) (hash (parse_agent (field agent)) (string "category")))
#   (order (field yyyymmdd) (desc (count (field *))))
#   (limit 30)))
# ;; (count *)
# ;; (count (field hoge))
# ;; (count (is_smartphone(parse_agent(agent))))
# ;; (count (if (= (field status) (number 500)) (number 1) (null)))

sub new {
    my ($this, %opts) = @_;
    my $ds = Data::SExpression->new({use_symbol_class => 1});
    my $plugin_modules = $opts{plugin_modules} || ['Net::Hadoop::Hive::QueryBuilder::DefaultPlugins'];
    my $plugins = $opts{plugins} || [];
    my $plugin_map = {};
    foreach my $m (@{$plugin_modules}) {
        push @{$plugins}, @{$m->plugins()};
    }
    foreach my $p (@$plugins) {
        $plugin_map->{$p->{name}} = $p;
    }
    return bless +{
        parser => $ds,
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
    $self->{plugin_map}->{$name}->{proc}
        or croak "unknown plugin type for name:" . $name;
}

sub type {
    my ($self, $name) = @_;
    $self->{plugin_map}->{$name}->{type}
        or croak "unknown plugin type for name:" . $name;
}

sub node_name {
    my ($self, $tree) = @_;
    $tree->[0]->name;
}

sub node_type {
    my ($self, $tree) = @_;
    $self->type($self->node_name($tree));
}

sub produce_value {
    my ($self, $tree) = @_;
    my $car = shift @$tree; # tree is cdr
    unless (ref($car) and ref($car) eq 'Data::SExpression::Symbol') {
        croak "all of 'car' must be symbol";
    }
    my $type = $self->type($car->name);
    if ($type eq 'f') {
        return $self->proc($car->name)->($self, @$tree);
    }
    elsif ($type eq 's') {
        return '(' . $self->proc($car->name)->($self, @$tree) . ')';
    }
    croak "argument node " . $car->name . " type is invalid: " . $type;
}

sub produce {
    my ($self, $tree) = @_;
    my $car = shift @$tree; # tree is cdr
    unless (ref($car) and ref($car) eq 'Data::SExpression::Symbol') {
        croak "all of 'car' must be symbol";
    }
    $self->proc($car->name)->($self, @$tree);
}

sub produce_or_alias {
    my ($self, $tree) = @_;
    my $exp = $self->produce($tree);
    $self->alias($exp) or $exp;
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
    my $exp = shift;
    my $q;
    try {
        $q = $self->{parser}->read($exp);
    } catch {
        $q = undef;
        $self->{error} = "S-expression parse error:" . $_;
    };
    return undef unless $q;

    my $toplevel = $q->[0];
    if ($toplevel->name ne 'query') {
        $self->{error} = "toplevel is not 'query'";
        return undef;
    }
    #TODO: utility to traverse node tree for total_checker
    #TODO: total_checker (ex: consistency between 'fields' and 'group', and so on...)

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
