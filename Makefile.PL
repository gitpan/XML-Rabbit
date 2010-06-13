
use strict;
use warnings;

 BEGIN { require 5.008; } 

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Consume XML with Moose and xpath queries',
  'AUTHOR' => 'Robin Smidsrød <robin@smidsrod.no>',
  'BUILD_REQUIRES' => {
    'English' => '0',
    'Test::More' => '0',
    'utf8' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'XML-Rabbit',
  'EXE_FILES' => [
    'bin/dump_xml_structure',
    'bin/xpath_extract'
  ],
  'LICENSE' => 'perl',
  'NAME' => 'XML::Rabbit',
  'PREREQ_PM' => {
    'Data::Visitor::Callback' => '0',
    'Encode' => '0',
    'Moose' => '0',
    'Moose::Role' => '0',
    'Moose::Util::TypeConstraints' => '0',
    'MooseX::Role::Parameterized' => '0',
    'Perl6::Junction' => '0',
    'Scalar::Util' => '0',
    'XML::LibXML' => '1.70'
  },
  'VERSION' => '0.0.1',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



