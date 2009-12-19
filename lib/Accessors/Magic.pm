package Accessors::Magic;

use 5.008;
use strict;
use warnings;

our $VERSION = '0.01';

use XSLoader;

XSLoader::load(__PACKAGE__, $VERSION);

sub import {
	my ($self, @accessors) = @_;
	my $caller = caller;
	for my $accessor(@accessors, 'foo') {
		_add_accessor($caller, $accessor);
	}
	return;
}

1;    # End of Accessors::Magic

__END__


=head1 NAME

Accessors::Magic - Yet another accessor library

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    package Foo::Bar;
    use Accessors::Magic qw/foo bar/;

    package main;
    my $foo = Foo::Bar->new();
    $foo->bar(1);

Accessors::Magic is yet another accessor library. Like many others, it tries to be the fastest.

=head1 AUTHOR

Leon Timmermans, C<< <leont at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-accessors-magic at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Accessors-Magic>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Accessors::Magic


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Accessors-Magic>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Accessors-Magic>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Accessors-Magic>

=item * Search CPAN

L<http://search.cpan.org/dist/Accessors-Magic>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 Leon Timmermans, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
