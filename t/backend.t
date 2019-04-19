
=head1 DESCRIPTION

This tests the L<Yancy::Backend::Static> directly.

=head1 SEE ALSO

L<Yancy>

=cut

use Test::More;
use Mojo::File qw( path tempdir );
use Yancy::Backend::Static;

my $temp = tempdir();
my $be = Yancy::Backend::Static->new(
    'static:' . $temp,
);

my %index_page = (
    path => 'index',
    title => 'Index',
    markdown => qq{# Index\n\nThis is my index page\n},
);

my $id = $be->create( page => \%index_page );
is $id, 'index', 'id is returned';
ok -e $temp->child( "$id.markdown" ), 'created index page exists';

my $item = $be->get( page => $id );
ok $item, 'id from create() works for get()';
is_deeply $item,
    {
        %index_page,
        html => qq{<h1>Index</h1>\n\n<p>This is my index page</p>\n},
    },
    'returned page is complete and correct';

$item = $be->get( page => 'NOT_FOUND' );
is $item, undef, 'get() NOT_FOUND returns undef';

my %about_page = (
    path => 'about',
    title => 'About',
    markdown => qq{# About\n\nThis is my about page\n},
);

$id = $be->create( page => \%about_page );
is $id, 'about', 'id is returned';
ok -e $temp->child( "$id.markdown" ), 'created about page exists';
$item = $be->get( page => $id );
ok $item, 'id from create() works for get()';
is_deeply $item,
    {
        %about_page,
        html => qq{<h1>About</h1>\n\n<p>This is my about page</p>\n},
    },
    'returned page is complete and correct';

my $result = $be->list( 'page' );
is $result->{total}, 2, 'list() reports two pages total';
is_deeply $result->{items},
    [
        {
            %about_page,
            html => qq{<h1>About</h1>\n\n<p>This is my about page</p>\n},
        },
        {
            %index_page,
            html => qq{<h1>Index</h1>\n\n<p>This is my index page</p>\n},
        }
    ],
    'list() reports correct items';

$result = $be->list( page => { path => 'index' } );
is $result->{total}, 1, 'list() reports one page matching path "index"';
is_deeply $result->{items},
    [
        {
            %index_page,
            html => qq{<h1>Index</h1>\n\n<p>This is my index page</p>\n},
        }
    ],
    'list() reports correct items matching path "index"';

done_testing;
