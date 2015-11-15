use strict;
use Test::More;
use File::Slurp;
use Sub::Override;
use Test::MockTime qw(set_absolute_time);


use_ok('Santaroid::Weather');
set_absolute_time('2015-11-08T20:00:00Z');

my $sub = Sub::Override->new('Santaroid::Weather::_build_forecast', sub {
    return Mojo::DOM->new(scalar read_file('t/data/2015-11-08.xml'));
});

my $weather = Santaroid::Weather->new(latitude=>59.251944, longitude=>10.418611);
is($weather->predict_weather, 'rain', 'predict_weather()');
is($weather->talk_about_weather, '', 'talk_about_weather()');



done_testing;
