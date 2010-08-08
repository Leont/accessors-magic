#!perl -T

use Test::More tests => 5;
use Test::Exception;
package Foo;

use Accessors::Magic;

has foo => ();
has bar => (is => 'rw');

sub new {
	my ($class, %values) = @_;
	bless \%values, $class;
}

package main;

my $foo = Foo->new(foo => 1, bar => 2);

is $foo->foo, 1, '$foo->foo == 1';
throws_ok { $foo->foo(42) } qr/Can't assign to 'foo'/, "Can't assign to 'foo'";
is $foo->bar, 2, '$foo->bar == 2';
lives_ok { $foo->bar(42) } 'Can assign to bar';
is $foo->bar, 42, '$foo->foo == 42';
