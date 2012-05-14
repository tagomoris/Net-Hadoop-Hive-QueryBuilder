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
        { type => 'f', name => 'length', proc => \&length_function },
        { type => 'f', name => 'reverse', proc => \&reverse_function },
        { type => 'f', name => 'concat', proc => \&concat_function },
        { type => 'f', name => 'concat_ws', proc => \&concat_ws },
        { type => 'f', name => 'substr', proc => \&substr_function },
        { type => 'f', name => 'upper', proc => \&upper },
        { type => 'f', name => 'lower', proc => \&lower },
        { type => 'f', name => 'trim', proc => \&trim },
        { type => 'f', name => 'ltrim', proc => \&ltrim },
        { type => 'f', name => 'rtrim', proc => \&rtrim },
        { type => 'f', name => 'regexp_replace', proc => \&regexp_replace },
        { type => 'f', name => 'regexp_extract', proc => \&regexp_extract },
        { type => 'f', name => 'parse_url', proc => \&parse_url },
        { type => 'f', name => 'get_json_object', proc => \&get_json_object },
        { type => 'f', name => 'space', proc => \&space },
        { type => 'f', name => 'repeat', proc => \&repeat },
        { type => 'f', name => 'ascii', proc => \&ascii },
        { type => 'f', name => 'lpad', proc => \&lpad },
        { type => 'f', name => 'rpad', proc => \&rpad },
        { type => 'f', name => 'split', proc => \&split_function },

        # { type => 'f', name => 'find_in_set', proc => \&find_in_set },

        { type => 'f', name => 'locate', proc => \&locate },

        # { type => 'f', name => 'str_to_map', proc => \& },
        # { type => 'f', name => 'sentences', proc => \& },
        # { type => 'f', name => 'ngrams', proc => \& },
        # { type => 'f', name => 'context_ngrams', proc => \& },
        # { type => 'f', name => 'in_file', proc => \& },
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

sub checkargs_and_build {
    use Data::Dumper;
    my ($b, $name, $desc, $argnum_param, @args) = @_;
    my $argnum = scalar(@args);
    my $ok = undef;
    foreach my $n (@$argnum_param) {
        next unless $n == $argnum;
        $ok = 1;
        last;
    }

    croak $desc unless $ok;
    $name . '(' . join(', ', map { $b->produce_value($_) } @args) . ')';
}

sub length_function {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'length', "(length (string a))", [1], @args)
}
sub reverse_function {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'reverse', "(reverse (string a))", [1], @args)
}
sub concat_function {
    my ($b,@args) = @_;
    if (scalar(@args) < 2) { die "(concat (string a) (string b) ...)"; }
    'concat(' . join(', ', map { $b->produce_value($_) } @args) . ')';
}
sub concat_ws {
    my ($b,@args) = @_;
    if (scalar(@args) < 3) { die "(concat_ws (string sep) (string a) (string b) ...)"; }
    'concat_ws(' . join(', ', map { $b->produce_value($_) } @args) . ')';
}
sub substr_function {
    my ($b,@args) = @_;
    my $desc = "(substr (string a) (number start)) or (substr (string a) (number start) (number end))";
    checkargs_and_build($b, 'substr', $desc, [2, 3], @args);
}
sub upper {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'upper', "(upper (string a))", [1], @args);
}
sub lower {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'lower', "(lower (string a))", [1], @args);
}
sub trim {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'trim', "(trim (string a))", [1], @args);
}
sub ltrim {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'ltrim', "(ltrim (string a))", [1], @args);
}
sub rtrim {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'rtrim', "(rtrim (string a))", [1], @args);
}
sub regexp_replace {
    my ($b,@args) = @_;
    my $desc = "(regexp_replace (string initial) (string pattern) (string replacement))";
    checkargs_and_build($b, 'regexp_replace', $desc, [3], @args);
}
sub regexp_extract {
    my ($b,@args) = @_;
    my $desc = "(regexp_extract (string subject) (string pattern) (number index))";
    checkargs_and_build($b, 'regexp_extract', $desc, [3], @args);
}
sub parse_url {
    my ($b,@args) = @_;
    my $desc = "(parse_url (string url) (string partToExtract) [(string keyToExtract)])";
    checkargs_and_build($b, 'parse_url', $desc, [2, 3], @args);
}
sub get_json_object {
    my ($b,@args) = @_;
    my $desc = "(get_json_object (string json_string) (string path))";
    checkargs_and_build($b, 'get_json_object', $desc, [2], @args);
}
sub space {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'space', "(space (number n))", [1], @args);
}
sub repeat {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'repeat', "(repeat (string a) (number n))", [2], @args);
}
sub ascii {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'ascii', "(ascii (string a))", [1], @args);
}
sub lpad {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'lpad', "(lpad (string a) (number len) (string pad))", [3], @args);
}
sub rpad {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'rpad', "(rpad (string a) (number len) (string pad))", [3], @args);
}
sub split_function {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'split', "(split (string a) (string pattern))", [2], @args);
}
sub find_in_set {} #TODO
sub locate {
    my ($b,@args) = @_;
    checkargs_and_build($b, 'locate', "(locate (string substr) (string str) [(number pos)])", [2, 3], @args);
}
# sub instr {} # use locate
sub str_to_map {} #TODO
sub sentences {} #TODO
sub ngrams {} #TODO
sub context_ngrams {} #TODO
sub in_file {} #TODO

1;
