package Git::Repository::Plugin::Diff;

use warnings;
use strict;

use 5.008_005;
our $VERSION = '0.01';

use Git::Repository::Plugin;
our @ISA = qw( Git::Repository::Plugin );

use Carp qw/croak/;

use Git::Repository::Plugin::Diff::Hunk;
use Git::Repository::Plugin::Diff::File;

sub _keywords {
    return qw( diff );
}    ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)

sub diff {
    my ( $repository, $file, $from_commit, $to_commit ) = @_;

    my $command =
      $repository->command( 'diff', $from_commit, $to_commit, $file );
    my @output = $command->final_output();

    # remove diff header - we cant get any usefull information from it
    splice @output, 0, 4;

    my $diff_file = Git::Repository::Plugin::Diff::File->new();

    # Parse the output.
    while ( my $hunk_header = shift @output ) {
        my $hunk =
          Git::Repository::Plugin::Diff::Hunk->parse_header($hunk_header);

        while ( !$hunk->is_finished ) {
            my $line = shift @output;
            if ( !defined $line ) {
                croak();
            }
        }

        $diff_file->add_hunk($hunk);
    }

    return $diff_file;
}

1;
__END__

=encoding utf-8

=head1 NAME

Git::Repository::Plugin::Diff - Add diff method to L<Git::Repository>.

=head1 SYNOPSIS

    # Load the plugin.
    use Git::Repository 'Diff';

    my $repository = Git::Repository->new();

    # Get the git diff information.
    my $blame_lines = $repository->diff( $file, "HEAD", "origin/master" );

=head1 DESCRIPTION

Git::Repository::Plugin::Diff adds diff method to L<Git::Repository>, which can be
used to determine diff between two commits/branches etc

=head1 AUTHOR

d.tarasov E<lt>d.tarasov@corp.mail.ruE<gt>

=head1 COPYRIGHT

Copyright 2020- d.tarasov

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
