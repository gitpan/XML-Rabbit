use strict;
use warnings;

package XML::Rabbit;
BEGIN {
  $XML::Rabbit::VERSION = '0.0.4';
}
use 5.008;

# ABSTRACT: Consume XML with Moose and xpath queries

1;


__END__
=pod

=encoding utf-8

=head1 NAME

XML::Rabbit - Consume XML with Moose and xpath queries

=head1 VERSION

version 0.0.4

=head1 SYNOPSIS

    my $xhtml = W3C::XHTML->new( file => 'index.xhtml' );
    print "Title: " . $xhtml->title . "\n";
    print "First image source: " . $xhtml->body->images->[0]->src . "\n";

    exit;

    package W3C::XHTML;
    use Moose;
    with 'XML::Rabbit::RootNode';

    has '+namespace_map' => (
        default => sub { {
            "xhtml" => "http://www.w3.org/1999/xhtml"
        } },
    );

    has 'title' => (
        isa         => 'Str',
        traits      => [qw(XPathValue)],
        xpath_query => '/xhtml:html/xhtml:head/xhtml:title',
    );

    has 'body' => (
        isa         => 'W3C::XHTML::Body',
        traits      => [qw(XPathObject)],
        xpath_query => '/xhtml:html/xhtml:body',
    );

    has 'all_anchors_and_images' => (
        traits      => ['XPathObjectList'],
        xpath_query => '//xhtml:a|//xhtml:img',
        isa_map     => {
            'xhtml:a'   => 'W3C::XHTML::Anchor',
            'xhtml:img' => 'W3C::XHTML::Image',
        },
    );

    no Moose;
    __PACKAGE__->meta->make_immutable();

    package W3C::XHTML::Body;
    use Moose;
    with 'XML::Rabbit::Node';

    has 'images' => (
        isa         => 'ArrayRef[W3C::XHTML::Image]',
        traits      => [qw(XPathObjectList)],
        xpath_query => './/xhtml:img',
    );

    no Moose;
    __PACKAGE__->meta->make_immutable();

    package W3C::XHTML::Image;
    use Moose;
    with 'XML::Rabbit::Node';

    has 'src' => (
        isa         => 'Str',
        traits      => [qw(XPathValue)],
        xpath_query => './@src',
    );

    has 'alt' => (
        isa         => 'Str',
        traits      => [qw(XPathValue)],
        xpath_query => './@alt',
    );

    has 'title' => (
        isa         => 'Str',
        traits      => [qw(XPathValue)],
        xpath_query => './@title',
    );

    no Moose;
    __PACKAGE__->meta->make_immutable();

    package W3C::XHTML::Anchor;
    use Moose;
    with 'XML::Rabbit::Node';

    has 'href' => (
        isa         => 'Str',
        traits      => [qw(XPathValue)],
        xpath_query => './@src',
    );

    has 'title' => (
        isa         => 'Str',
        traits      => [qw(XPathValue)],
        xpath_query => './@title',
    );

    no Moose;
    __PACKAGE__->meta->make_immutable();

    1;

=head1 DESCRIPTION

XML::Rabbit is a simple Moose-based base class you can use to make simple
XPath-based XML extractors. Each attribute in your class is linked to an
XPath query that is executed on your XML document when you request the
value.

Also notice that if you specify an xpath_query that can return multiple
types, you need to specify C<isa_map> instead of just specifying the types
as a union type constraint in C<isa>. If you specify C<isa_map> you should
not specify C<isa> aswell, as it will be overridden by the trait. The trait
will wrap the type constraint union in an ArrayRef if the trait name is
XPathObjectList and as a HashRef if the trait name is XPathObjectMap. As all
the traits that end with List return array references, their C<isa> must be
an ArrayRef. The same is valid for the *Map traits, just that they return
HashRef instead of ArrayRef.

The namespace prefix used in C<isa_map> MUST be specified in the
C<namespace_map>. If a prefix is used in C<isa_map> without a corresponding
entry in C<namespace_map> an exception will be thrown.

=head1 CAVEATS

Be aware of the syntax of XPath when used with namespaces. You should almost
always define C<namespace_map> when dealing with XML that use namespaces.
Namespaces explicitly declared in the XML are usable with the prefix
specified in the XML (except if you use C<isa_map>). Be aware that a prefix
must usually be declared for the default namespace (xmlns=...) to be able to
use it in XPath queries. See the example above (on XHTML) for details. See
L<XML::LibXML::Node/findnodes> for more information.

Because XML::Rabbit uses XML::LibXML's DOM parser it is limited to handling
XML documents that can fit in available memory. Unfortunately there is no
easy way around this, because XPath queries need to work on a tree model,
and I am not aware of any way of doing that without keeping the document in
memory. Luckily XML::LibXML's DOM implementation is written in C, so it
should use much less memory than a pure Perl DOM parser.

=head1 SEMANTIC VERSIONING

This module uses semantic versioning concepts from L<http://semver.org/>.

=head1 ACKNOWLEDGEMENTS

The following people have helped to review or otherwise encourage
me to work on this module.

Chris Prather (perigrin)

Matt S. Trout (mst)

Stevan Little (stevan)

=head1 SEE ALSO

=over 4

=item *

L<XML::Toolkit>

=item *

L<Moose>

=item *

L<XML::LibXML>

=back

=for :stopwords CPAN AnnoCPAN RT CPANTS Kwalitee diff

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc XML::Rabbit

=head2 Websites

=over 4

=item *

Search CPAN

L<http://search.cpan.org/dist/XML-Rabbit>

=item *

AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/XML-Rabbit>

=item *

CPAN Ratings

L<http://cpanratings.perl.org/d/XML-Rabbit>

=item *

CPAN Forum

L<http://cpanforum.com/dist/XML-Rabbit>

=item *

RT: CPAN's Bug Tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=XML-Rabbit>

=item *

CPANTS Kwalitee

L<http://cpants.perl.org/dist/overview/XML-Rabbit>

=item *

CPAN Testers Results

L<http://cpantesters.org/distro/X/XML-Rabbit.html>

=item *

CPAN Testers Matrix

L<http://matrix.cpantesters.org/?dist=XML-Rabbit>

=item *

Source Code Repository

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<git://github.com/robinsmidsrod/XML-Rabbit.git>

=back

=head2 Bugs

Please report any bugs or feature requests to C<bug-xml-rabbit at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-Rabbit>.  I will be
notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 AUTHOR

Robin Smidsrød <robin@smidsrod.no>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Robin Smidsrød.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

