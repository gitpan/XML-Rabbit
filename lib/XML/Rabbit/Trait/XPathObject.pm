use strict;
use warnings;

package XML::Rabbit::Trait::XPathObject;
{
  $XML::Rabbit::Trait::XPathObject::VERSION = '0.4.0';
}
use Moose::Role;

with 'XML::Rabbit::Trait::XPath';

# ABSTRACT: XML DOM object xpath extractor trait

around '_process_options' => sub {
    my ($orig, $self, $name, $options, @rest) = @_;

    $self->$orig($name, $options, @rest);

    # This should really be:
    # has '+isa' => ( required => 1 );
    # but for some unknown reason Moose doesn't allow that
    confess("isa attribute is required") unless defined( $options->{'isa'} );
};


has 'isa_map' => (
    is      => 'ro',
    isa     => 'HashRef[Str]',
    lazy    => 1,
    default => sub { +{} },
);


sub _build_default {
    my ($self) = @_;
    return sub {
        my ($parent) = @_;
        my $node = $self->_find_node(
            $parent,
            $self->_resolve_xpath_query( $parent ),
        );
        $self->_convert_isa_map( $parent );
        my $class = $self->_resolve_class();
        return $self->_create_instance( $parent, $class, $node );
    };
}

Moose::Util::meta_attribute_alias('XPathObject');

no Moose::Role;

1;

__END__

=pod

=encoding utf-8

=head1 NAME

XML::Rabbit::Trait::XPathObject - XML DOM object xpath extractor trait

=head1 VERSION

version 0.4.0

=head1 SYNOPSIS

    package MyXMLSyntaxNode;
    use Moose;
    with 'XML::Rabbit::Node';

    has 'first_person' => (
        isa         => 'MyXMLSyntax::Person',
        traits      => [qw(XPathObject)],
        xpath_query => './person[1]',
    );

    no Moose;
    __PACKAGE__->meta->make_immutable();

    1;

=head1 DESCRIPTION

This module provides the extraction of complex values (subtrees) from an XML
node based on an XPath query. The subtree is used as input for the
constructor of the class specified in the isa attribute.

See L<XML::Rabbit> for a more complete example.

=head1 ATTRIBUTES

=head2 isa_map

Specifies the prefix:tag to class name mapping used with union xpath
queries. See L<XML::Rabbit> for more detailed information.

=head1 METHODS

=head2 _build_default

Returns a coderef that is run to build the default value of the parent attribute. Read Only.

=head1 AUTHOR

Robin Smidsrød <robin@smidsrod.no>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Robin Smidsrød.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
