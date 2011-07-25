
use strict;
use warnings;

use Test::More;
use AnyEvent::setTimeout;
use AnyEvent;

{
	my $cv = AnyEvent->condvar;

	my $i = 0;
	my $timer; $timer = setInterval(sub {
		if (++$i > 3) {
			$cv->send;
			clearInterval($timer);
		}
	}, 10);
	$cv->recv;

	is $i, 4;
};

{
	my $cv = AnyEvent->condvar;

	my $i = 0;
	my $timer; $timer = setInterval(sub {
		if (++$i > 3) {
			$cv->send;
			clearInterval($timer);
		}
		die "foo";
	}, 10);

	$cv->recv;

	is $i, 4;
};

done_testing;
