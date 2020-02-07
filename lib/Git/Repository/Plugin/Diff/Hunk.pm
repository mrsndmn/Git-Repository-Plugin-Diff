package Git::Repository::Plugin::Diff::Hunk;

use warnings;
use strict;

use Carp qw/croak/;

sub new {
    my ( $pkg, %args ) = @_;
    my $from_line_start = delete $args{from_line_start};
    my $from_line_count = delete $args{from_line_count};
    my $to_line_start   = delete $args{to_line_start};
    my $to_line_count   = delete $args{to_line_count};
    my $header          = delete $args{_header};

    return bless {
        _header => $header,

        from_line_start     => $from_line_start,
        from_line_count     => $from_line_count,
        from_line_processed => 0,
        from_lines          => [],

        to_line_start     => $to_line_start,
        to_line_count     => $to_line_count,
        to_line_processed => 0,
        to_lines          => [],

    }, $pkg;
}

# @@ -5,3 +5,5 @@
# @@ -0,0 +1 @@
# @@ -1,7 +0,0 @@
# @@ -1,7 +1 @@

sub parse_header {
    my ( $pkg, $str ) = @_;

    my ( $from_file_line_numbers, $to_file_line_numbers ) =~
      /^\@\@ \s \-(\S+) \s \+(\S+) \s \@\@$/x;

    my ( $from_line_start, $from_line_count ) =
      $pkg->_parse_hunk_numbers($from_file_line_numbers);

    my ( $to_line_start, $to_line_count ) =
      $pkg->_parse_hunk_numbers($to_file_line_numbers);

    return $pkg->new(
        _header         => $str,
        from_line_start => $from_line_start,
        from_line_count => $from_line_count,
        to_line_start   => $to_line_start,
        to_line_count   => $to_line_count,
    );
}

sub _parse_hunk_numbers {
    my ( $pkg, $numbers_str ) = @_;
    my ( $line_start, $line_count ) = split ',', $numbers_str;
    $line_count //= 1;
    return $line_start, $line_count;
}

sub add_line {
    my ( $self, $line ) = @_;

    if ( $line =~ /^\s/ ) {
        $self->process_from_line($line);
        $self->process_to_line($line);
    }
    elsif ( $line =~ /^\+/ ) {
        $self->process_to_line($line);
    }
    elsif ( $line =~ /^\-/ ) {
        $self->process_from_line($line);
    }
    else {
        croak "Malformed diff line: '$line'";
    }

    return 1;
}

sub process_from_line {
    my ( $self, $line ) = @_;
    $self->_process_line( "from", $line );
    return;
}

sub process_to_line {
    my ( $self, $line ) = @_;
    $self->_process_line( "to", $line );
    return;
}

sub _process_line {
    my ( $self, $kind, $line ) = @_;
    my $lines_key = "${kind}_lines";
    push @{ $self->{$lines_key} }, $line;

    if ( scalar @{ $self->{$lines_key} } > $self->{"${kind}_line_count"} ) {
        croak "Malformed diff: processed `$kind` lines"
          . "is gather than was declared in hunk header: "
          . $self->{_header};
    }
    return;
}

sub is_finished {
    my ($self) = @_;

    my $from_cnt_eq = $self->{from_line_processed} == $self->{from_line_count};
    my $to_cnt_eq   = $self->{to_line_processed} == $self->{to_line_count};

    return $from_cnt_eq && $to_cnt_eq;
}

sub from_lines {
    my ($self) = @_;
    return @{ $self->{from_lines} };
}

sub to_lines {
    my ($self) = @_;
    return @{ $self->{to_lines} };
}

1;
