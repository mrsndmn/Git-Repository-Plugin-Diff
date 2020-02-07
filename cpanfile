requires 'perl', '5.008005';

requires 'Git::Repository::Plugin', '1';

on test => sub {
    requires 'Test::More', '0.96';
};
