# Name

Web::Components::Role::TT - Applies Template as Web::Component role

# Synopsis

    use Moo;

    with 'Web::Components::Role';
    with 'Web::Components::Role::TT';

    $rendered_template = $self->render_template( $request_object, $stash );

# Description

Uses [Template](https://metacpan.org/pod/Template) to render templates, typically producing a page of HTML.
It is meant to be used in conjunction with [Web::Components](https://metacpan.org/pod/Web::Components) and
[Web::ComposableRequest](https://metacpan.org/pod/Web::ComposableRequest) as it's API assumes these are used

Templates are assumed to be encoded as `utf8`

# Configuration and Environment

Defines the following attributes;

- `templates`

    A lazily evaluated directory which defaults to `templates` in the configuration
    root directory. This is where the templates are stored

# Subroutines/Methods

## `render_template`

    $rendered_template = $self->render_template( $request_object, $stash );

The `$request_object` is an instance of [Web::ComposableRequest](https://metacpan.org/pod/Web::ComposableRequest). The
`$stash` hash reference may contain a `config` attribute if not the
invocant is expected to provide a `config` object. The `$stash` should
also contain `skin` and `page` attributes. The `page` hash reference
should contain a `layout` attribute

The path to the template file is `templates/<skin>/<layout>.tt`. The
`skin` and `layout` attributes default to the values of the configuration
object

If the consuming class has a `stash_template_functions` method it is called
passing in the `request` and `stash` arguments. It is expected that this
method will add code references to the stash that can be called from the
templates

# Diagnostics

The compiled templates are stored in subdirectories below the configuration
temporary directory

# Dependencies

- [Class::Usul](https://metacpan.org/pod/Class::Usul)
- [File::DataClass](https://metacpan.org/pod/File::DataClass)
- [Moo](https://metacpan.org/pod/Moo)
- [Template](https://metacpan.org/pod/Template)
- [Unexpected](https://metacpan.org/pod/Unexpected)

# Incompatibilities

There are no known incompatibilities in this module

# Bugs and Limitations

There are no known bugs in this module. Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Web-Components-Role-TT.
Patches are welcome

# Acknowledgements

Larry Wall - For the Perl programming language

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# License and Copyright

Copyright (c) 2015 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/pod/perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
