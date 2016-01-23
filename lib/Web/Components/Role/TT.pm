package Web::Components::Role::TT;

use 5.010001;
use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.4.%d', q$Rev: 3 $ =~ /\d+/gmx );

use File::DataClass::Constants qw( EXCEPTION_CLASS NUL TRUE );
use File::DataClass::Types     qw( Directory Object );
use Template;
use Unexpected::Functions      qw( PathNotFound throw );
use Moo::Role;

requires qw( config ); # layout root skin tempdir

# Attribute constructors
my $_build__templater = sub {
   my $self        =  shift;
   my $args        =  {
      COMPILE_DIR  => $self->config->tempdir->catdir( 'ttc' ),
      COMPILE_EXT  => 'c',
      ENCODING     => 'utf8',
      RELATIVE     => TRUE,
      INCLUDE_PATH => [ $self->templates->pathname ], };
   my $template    =  Template->new( $args ) or throw $Template::ERROR;

   return $template;
};

# Public attributes
has 'templates'  => is => 'lazy', isa => Directory, coerce => TRUE,
   builder       => sub { $_[ 0 ]->config->root->catdir( 'templates' ) };

# Private attributes
has '_templater' => is => 'lazy', isa => Object, builder => $_build__templater;

# Public methods
sub render_template {
   my ($self, $stash) = @_; $stash //= {};

   my $result =  NUL;
   my $conf   =  $stash->{config} //= $self->config;
   my $page   =  $stash->{page  } //= {};
   my $layout = ($page->{layout } //= $conf->layout);

   if (ref $layout) {
      $self->_templater->process( $layout, $stash, \$result )
         or throw $self->_templater->error;
   }
   else {
      my $skin = $stash->{skin} //= $conf->skin;
      my $path = $self->templates->catfile( $skin, "${layout}.tt" );

      $path->exists or throw PathNotFound, [ $path ];
      $self->_templater->process
         ( $path->abs2rel( $self->templates ), $stash, \$result )
         or throw $self->_templater->error;
   }

   return $result;
}

1;

__END__

=pod

=encoding utf-8

=begin html

<a href="https://travis-ci.org/pjfl/p5-web-components-role-tt"><img src="https://travis-ci.org/pjfl/p5-web-components-role-tt.svg?branch=master" alt="Travis CI Badge"></a>
<a href="http://badge.fury.io/pl/Web-Components-Role-TT"><img src="https://badge.fury.io/pl/Web-Components-Role-TT.svg" alt="CPAN Badge"></a>
<a href="http://cpants.cpanauthors.org/dist/Web-Components-Role-TT"><img src="http://cpants.cpanauthors.org/dist/Web-Components-Role-TT.png" alt="Kwalitee Badge"></a>

=end html

=head1 Name

Web::Components::Role::TT - Applies Template as a Moo::Role

=head1 Synopsis

   use Moo;

   with 'Web::Components::Role::TT';

   $rendered_template = $self->render_template( $stash );

=head1 Description

Uses L<Template> to render templates, typically producing a page of HTML.
It is meant to be used in conjunction with L<Web::Components> and
L<Web::ComposableRequest> as it's API assumes these are used

Templates are assumed to be encoded as C<utf8>

=head1 Configuration and Environment

Defines the following attributes;

=over 3

=item C<templates>

A lazily evaluated directory which defaults to F<templates> in the configuration
root directory. This is where the templates are stored

The path to the template file is F<< templates/<skin>/<layout>.tt >>. The
C<skin> and C<layout> attributes default to the values of the configuration
object

=back

=head1 Subroutines/Methods

=head2 C<render_template>

   $rendered_template = $self->render_template( $stash );

The C<$stash> hash reference may contain a C<config> attribute, otherwise the
invocant is expected to provide a C<config> object. The C<$stash> should also
contain C<skin> and C<page> attributes. The C<page> hash reference should
contain a C<layout> attribute

=head1 Diagnostics

The compiled templates are stored in subdirectories below the configuration
temporary directory

=head1 Dependencies

=over 3

=item L<File::DataClass>

=item L<Moo>

=item L<Template>

=item L<Unexpected>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module. Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Web-Components-Role-TT.
Patches are welcome

=head1 Acknowledgements

Larry Wall - For the Perl programming language

=head1 Author

Peter Flanigan, C<< <pjfl@cpan.org> >>

=head1 License and Copyright

Copyright (c) 2016 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
# vim: expandtab shiftwidth=3:
