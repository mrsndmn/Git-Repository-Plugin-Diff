package Git::Repository::Plugin::Diff::File;

use warnings;
use strict;

sub new {
    my ($class) = @_;
    return bless [], $class;
}

sub add_hunk {
    my ( $self, $hunk ) = @_;
    return push @$self, $hunk;
}

sub get_hunks {
    my ($self) = @_;
    return @$self;
}

1;
