package Net::Hadoop::Hive::QueryBuilder::Functions::String;

use strict;
use warnings;
use Carp;

use Data::SExpression::Symbol;

# functions
# type
# f: formula
# s: sentence
# g: grammer (hql reserved word)
# q: query

sub functions {
    +[
#        { type => 'f', name => '', proc => \&foobar },
    ]
}

sub plugin_proc {
    my $name = shift;
    foreach my $p (@{functions()}) {
        if ($p->{name} eq $name) {
            return $p->{proc};
        }
    }
    return undef;
}

sub length_function {
}
sub reverse_function {
}
sub concat_function {
}
sub concat_ws {
}
sub substr_function {
}
sub upper {
}
sub lower {
}
sub trim {
}
sub ltrim {
}
sub rtrim {
}
sub regexp_replace {
}
sub regexp_extract {
}
sub parse_url {
}
sub get_json_object {
}
sub space {
}
sub repeat {
}
sub ascii {
}
sub lpad {
}
sub rpad {
}
sub split_function {
}
sub find_in_set {} #TODO
sub locate {
}
# sub instr {} # use locate
sub str_to_map {} #TODO
sub sentences {} #TODO
sub ngrams {} #TODO
sub context_ngrams {} #TODO
sub in_file {} #TODO

1;
