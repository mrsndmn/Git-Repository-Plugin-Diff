# NAME

[Git::Repository::Plugin::Diff](https://metacpan.org/pod/Git::Repository::Plugin::Diff) - Add diff method to [Git::Repository](https://metacpan.org/pod/Git%3A%3ARepository).

# SYNOPSIS

    # Load the plugin.
    use Git::Repository 'Diff';

    my $repository = Git::Repository->new();

    # Get the git diff information.
    my @hunks = $repository->diff( $file, "HEAD", "HEAD~1" );
    my @other_hunks = $repository->diff( $file, "HEAD", "origin/master" );

    my $first_hunk = shift @hunks;
    _dump_diff($first_hunk);

    sub _dump_diff {
        my ($hunk) = @_;
        for my $l ($first_hunk->to_lines) {
            my ($line_num, $line_content) = @$l;
            print("+ $line_num: $line_content\n")
        }
        for my $l ($first_hunk->from_lines) {
            my ($line_num, $line_content) = @$l;
            print("- $line_num: $line_content\n")
        }
    }

# DESCRIPTION

Git::Repository::Plugin::Diff adds diff method to [Git::Repository](https://metacpan.org/pod/Git%3A%3ARepository), which can be
used to determine diff between two commits/branches etc

## diff()

Returns list of hunks diff for specified file. For specified commits (or branches).

    my @hunks = $repository->diff( $file, "HEAD", "HEAD~1" );

# AUTHOR

d.tarasov <d.tarasov@corp.mail.ru>

# COPYRIGHT

Copyright 2020- d.tarasov

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
