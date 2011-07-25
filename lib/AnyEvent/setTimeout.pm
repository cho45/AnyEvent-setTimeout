package AnyEvent::setTimeout;

use strict;
use warnings;

use AnyEvent;
use Exporter::Lite;

our $VERSION = '0.01';
our @EXPORT = qw(setTimeout clearTimeout setInterval clearInterval);

my %timeouts;
my $timer_id = 0;
my $threads = AnyEvent->condvar;
$threads->begin;

END {
	$threads->end;
	$threads->recv;
};

sub setTimeout (&$) {
	my ($sub, $time) = @_;
	$threads->begin;
	my $id = $timer_id++;
	$timeouts{$id} = AE::timer $time / 1000, 0, sub {
		eval {
			$sub->();
		};
		clearTimeout(\$id);
		die $@ if $@;
	};
	\$id;
}

sub clearTimeout ($) {
	my ($id) = @_;
	$threads->end;
	delete $timeouts{$$id};
}

sub setInterval (&$) {
	my ($sub, $time) = @_;
	my $id;
	my $loop; $loop = sub {
		$$id = setTimeout(sub {
			eval {
				$sub->();
			};
			$loop->();
			die $@ if $@;
		}, $time);
	};
	$loop->();
	$id;
}

*clearInterval = \&clearTimeout;


1;
__END__

=encoding utf8

=head1 NAME

AnyEvent::setTimeout - JavaScript-like timeout functions

=head1 SYNOPSIS

  use AnyEvent::setTimeout;

  setTimeout(sub {
    warn "1sec elapsed!";
  }, 1000);


=head1 DESCRIPTION

AnyEvent::setTimeout is JavaScript-like timeout modules.

=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
