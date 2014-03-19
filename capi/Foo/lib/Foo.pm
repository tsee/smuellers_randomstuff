package Foo;
use 5.014002;
use warnings;

use Module::WithCAPI;
our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Foo', $VERSION);

1;
__END__

=head1 NAME

Foo - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Foo;
  blah blah blah

=head1 DESCRIPTION

Blah blah blah.

=head2 EXPORT

=head1 SEE ALSO

=head1 AUTHOR

Steffen Mueller, E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
