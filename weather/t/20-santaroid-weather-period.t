use strict;
use Test::More;
use Test::MockTime qw(set_absolute_time);
use File::Slurp;
use Mojo::DOM;

use_ok('Santaroid::Weather::Period');

set_absolute_time('2015-11-08T20:00:00Z');
my $dom = Mojo::DOM->new(scalar read_file('t/data/2015-11-08.xml'));
my $period = Santaroid::Weather::Period->new(time_nodes=>$dom->find('time'));


my $next_hours = $period->next_n_hours(10);
is($next_hours->time_nodes->size, 40, 'next_n_hours()');

is_deeply($next_hours->rain, {hours=>5, sum=>6.2, max=>2.5, min=>'0.0', avg=>0.62}, 'rain()');

is_deeply($next_hours->temperature, {avg=>'10.12', max=>'10.9', min=>'9.1'}, 'temperature()');

is_deeply($next_hours->wind, {max=>'14.4', hours=>6, avg=>'8.71', min=>'4.1'}, 'wind()');



done_testing;
