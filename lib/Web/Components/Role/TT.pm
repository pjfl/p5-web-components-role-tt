package Web::Components::Role::TT;

use 5.010001;
use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 2 $ =~ /\d+/gmx );

use Class::Usul::Constants  qw( EXCEPTION_CLASS NUL TRUE );
use Class::Usul::Functions  qw( throw );
use File::DataClass::Types  qw( Directory Object );
use Template;
use Unexpected::Functions   qw( PathNotFound );
use Moo::Role;

requires qw( config );

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
   my ($self, $req, $stash) = @_;

   $self->can( 'stash_template_functions' )
      and $self->stash_template_functions( $req, $stash );

   my $result =  NUL;
   my $conf   =  $stash->{config} //= $self->config;
   my $skin   =  $stash->{skin  } //= $conf->skin;
   my $page   =  $stash->{page  } //= {};
   my $layout = ($page->{layout } //= $conf->layout).'.tt';
   my $path   =  $self->templates->catfile( $skin, $layout );

   $path->exists or throw PathNotFound, [ $path ];
   $self->_templater->process
      ( $path->abs2rel( $self->templates ), $stash, \$result )
      or throw $self->_templater->error;

   return $result;
}

1;

__END__

=pod

=encoding utf-8

=head1 Name

Web::Components::Role::TT - Applies Template as Web::Component role

=head1 Synopsis

   use Moo;

   with 'Web::Components::Role';
   with 'Web::Components::Role::TT';

   $rendered_template = $self->render_template( $request_object, $stash );

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

=back

=head1 Subroutines/Methods

=head2 C<render_template>

   $rendered_template = $self->render_template( $request_object, $stash );

The C<$request_object> is an instance of L<Web::ComposableRequest>. The
C<$stash> hash reference may contain a C<config> attribute if not the
invocant is expected to provide a C<config> object. The C<$stash> should
also contain C<skin> and C<page> attributes. The C<page> hash reference
should contain a C<layout> attribute

The path to the template file is F<< templates/<skin>/<layout>.tt >>. The
C<skin> and C<layout> attributes default to the values of the configuration
object

If the consuming class has a C<stash_template_functions> method it is called
passing in the C<request> and C<stash> arguments. It is expected that this
method will add code references to the stash that can be called from the
templates

=head1 Diagnostics

The compiled templates are stored in subdirectories below the configuration
temporary directory

=head1 Dependencies

=over 3

=item L<Class::Usul>

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

Copyright (c) 2015 Peter Flanigan. All rights reserved

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
