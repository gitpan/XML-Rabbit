use strict;
use warnings;

package XML::Rabbit::Sugar;
{
  $XML::Rabbit::Sugar::VERSION = '0.2.1';
}

# ABSTRACT: Sugar functions for easier declaration of xpath attributes

use Scalar::Util qw(blessed);
use Carp qw(confess);

use Moose 0.89 (); # no magic, just load
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_meta => [qw(
        add_xpath_namespace
        has_xpath_value
        has_xpath_value_list
        has_xpath_value_map
        has_xpath_object
        has_xpath_object_list
        has_xpath_object_map
        finalize_class
    )],
    also => 'Moose',
);


sub add_xpath_namespace {
    my ($meta, $namespace, $url) = @_;
    my $attr = $meta->find_attribute_by_name('namespace_map');
    confess("namespace_map attribute not present") unless blessed($attr);
    my $default = $attr->default;
    my $new_default = sub { my $hash = $default->(@_); $hash->{$namespace} = $url; return $hash; };
    my $new_attr = $attr->clone_and_inherit_options(default => $new_default);
    $meta->add_attribute($new_attr);
    return 1;
}


sub has_xpath_value {
    my ($meta, $attr_name, $xpath_query, @moose_params) = @_;
    $meta->add_attribute($attr_name,
        is          => 'ro',
        isa         => 'Str',
        traits      => [qw( XPathValue String )],
        xpath_query => $xpath_query,
        default     => '',
        @moose_params,
    );
    return 1;
}


sub has_xpath_value_list {
    my ($meta, $attr_name, $xpath_query, @moose_params) = @_;
    $meta->add_attribute($attr_name,
        isa         => 'ArrayRef[Str]',
        traits      => [qw( XPathValueList Array )],
        xpath_query => $xpath_query,
        default     => sub { [] },
        @moose_params,
    );
    return 1;
}


sub has_xpath_value_map {
    my ($meta, $attr_name, $xpath_query, $xpath_key, $xpath_value, @moose_params) = @_;
    $meta->add_attribute($attr_name,
        isa         => 'HashRef[Str]',
        traits      => [qw( XPathValueMap Hash )],
        xpath_query => $xpath_query,
        xpath_key   => $xpath_key,
        xpath_value => $xpath_value,
        default     => sub { +{} },
        @moose_params,
    );
    return 1;
}



sub has_xpath_object {
    my ($meta, $attr_name, $xpath_query, $isa, @moose_params) = @_;
    my @isa = ref($isa) eq 'HASH'
            ? ( isa_map => $isa )
            : ( isa     => $isa )
    ;
    $meta->add_attribute($attr_name, @isa,
        traits      => [qw( XPathObject )],
        xpath_query => $xpath_query,
        @moose_params,
    );
    return 1;
}



sub has_xpath_object_list {
    my ($meta, $attr_name, $xpath_query, $isa, @moose_params) = @_;
    my @isa = ref($isa) eq 'HASH'
            ? ( isa_map => $isa )
            : ( isa     => 'ArrayRef[' . $isa . ']' )
    ;
    $meta->add_attribute($attr_name, @isa,
        traits      => [qw( XPathObjectList Array )],
        xpath_query => $xpath_query,
        default     => sub { +[] },
        @moose_params,
    );
    return 1;
}



sub has_xpath_object_map {
    my ($meta, $attr_name, $xpath_query, $xpath_key, $isa, @moose_params) = @_;
    my @isa = ref($isa) eq 'HASH'
            ? ( isa_map => $isa )
            : ( isa     => 'HashRef[' . $isa . ']' )
    ;
    $meta->add_attribute($attr_name, @isa,
        traits      => [qw( XPathObjectMap Hash )],
        xpath_query => $xpath_query,
        xpath_key   => $xpath_key,
        default     => sub { +{} },
        @moose_params,
    );
    return 1;
}


sub finalize_class {
    my ($meta) = @_;
    $meta->make_immutable();
    return 1; # so we can avoid the 1; at the end of the file
}

no Moose::Exporter;

1;

__END__

=pod

=encoding utf-8

=head1 NAME

XML::Rabbit::Sugar - Sugar functions for easier declaration of xpath attributes

=head1 VERSION

version 0.2.1

=head1 FUNCTIONS

=head2 add_xpath_namespace($namespace, $url)

Adds the XPath namespace with its associated url to the namespace_map hash.

=head2 has_xpath_value($attr_name, $xpath_query, @moose_params)

Extracts a single string according to the xpath query specified.  The
attribute isa parameter is automatically set to C<Str>.  The attribute native
trait is automatically set to C<String>.

    has_xpath_value 'name' => './name',
        ...
    ;

=head2 has_xpath_value_list($attr_name, $xpath_query, @moose_params)

Extracts an array of strings according to the xpath query specified.  The
attribute isa parameter is automatically set to C<ArrayRef[Str]>.  The
attribute native trait is automatically set to C<Array>.

    has_xpath_value_list 'streets' => './street',
        ...
    ;

=head2 has_xpath_value_map($attr_name, $xpath_query, $xpath_key, $xpath_value, @moose_params)

Extracts a hash of strings according to the xpath query specified.  The
attribute isa parameter is automatically set to C<HashRef[Str]>.  The
attribute native trait is automatically set to C<Hash>.  The xpath query
should represent the multiple elements you want to retrieve.  The xpath_key
and xpath_value queries must specify how to lookup the key and value for
each hash entry.  Most likely you'd want to use relative queries for the key
and value like the example below shows.

    has_xpath_value_map 'employee_map' => './employees/*',
        './@ssn' => './name',
        ...
    ;

=head2 has_xpath_object($attr_name, $xpath_query, $isa, @moose_params)

Extracts a single object according to the xpath query specified.  The
attribute isa parameter is automatically set to a the specified class name. 
In the example below it would be set to C<My::Department>.

    has_xpath_object 'department' => './department' => 'My::Department';

=head2 has_xpath_object($attr_name, $xpath_query, $isa_map, @moose_params)

Extracts a single object according to the xpath query specified.  The
attribute isa parameter is automatically set to a union of the values in the
specified hash.  In the example below it would be set to
C<My::Department|My::Team>.

    has_xpath_object 'department' => './department|./team' =>
        {
            'department' => 'My::Department',
            'team'       => 'My::Team',
        },
        ...
    ;

=head2 has_xpath_object_list($attr_name, $xpath_query, $isa, @moose_params)

Extracts an array of objects according to the xpath query specified.  The
attribute isa parameter is automatically set to C<ArrayRef[My::Customer]>
(in example below).  The attribute native trait is automatically set to
C<Array>.

    has_xpath_object_list 'customers' => './customer' => 'My::Customer';

=head2 has_xpath_object_list($attr_name, $xpath_query, $isa_map, @moose_params)

Extracts an array of objects according to the xpath query specified.  The
attribute isa parameter is automatically set to
C<ArrayRef[My::Customer|My::Partner]> (in example below).  The attribute
native trait is automatically set to C<Array>.

    has_xpath_object_list 'externals' => './customer|./partner' =>
        {
            'customer' => 'My::Customer',
            'partner'  => 'My::Partner',
        },
        ...
    ;

=head2 has_xpath_object_map($attr_name, $xpath_query, $xpath_key, $isa, @moose_params)

Extracts a hash of objects according to the xpath query specified.  The
attribute isa parameter is automatically set to C<HashRef[My::Product]> (see
example).  The attribute native trait is automatically set to C<Hash>.  The
xpath query should represent the multiple elements you want to retrieve. 
The xpath_key query must specify how to lookup the key for each hash entry. 
Most likely you'd want to use relative queries for the key like the example
below shows.

    has_xpath_object_map 'product_map' => './products/*',
        './@code' => 'My::Product',
        ...
    ;

=head2 has_xpath_object_map($attr_name, $xpath_query, $xpath_key, $isa_map, @moose_params)

Extracts a hash of objects according to the xpath query specified.  The
attribute isa parameter is automatically set to
C<HashRef[My::Product|My::Service]> (see example).  The attribute native
trait is automatically set to C<Hash>.  The xpath query should represent the
multiple elements you want to retrieve.  The xpath_key query must specify
how to lookup the key for each hash entry.  Most likely you'd want to use
relative queries for the key like the example below shows.

    has_xpath_object_map 'merchandise_map' => './products/*|./services/*',
        './@code' => {
                        'service' => 'My::Service',
                        'product' => 'My::Product',
                     },
        ...
    ;

=head2 finalize_class()

Convenience function that calls __PACKAGE__->meta->make_immutable() for you.
Always returns true value.

=head1 AUTHOR

Robin Smidsrød <robin@smidsrod.no>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Robin Smidsrød.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
