package Santaroid::Weather;

# Try to summarize the weather as a single state

use Moose;
use Mojo::YR;
use Santaroid::Weather::Period;


has 'latitude' => (is=>'rw', isa=>'Num', required=>1);

has 'longitude' => (is=>'rw', isa=>'Num', required=>1);

has 'forecast' => (is=>'rw', builder=>'_build_forecast', lazy=>1);


sub _build_forecast {
    my ($self) = @_;
    my $yr = Mojo::YR->new;
    return $yr->location_forecast([$self->latitude, $self->longitude]);
}


sub whole_period {
    my ($self) = @_;
    my $time_nodes = $self->forecast->find('time');
    return Santaroid::Weather::Period->new(time_nodes=>$time_nodes);
}


sub what_to_say {
    my ($self) = @_;
    my $period = $self->whole_period->next_n_hours(8);
    
    my $rain = $period->rain;
    return "rain" if $rain->{hours}>4 || $rain->{sum}>3;
    return "some-rain" if $rain->{max} > 0.2;

    my $temperature = $period->temperature;
    return "frost" if $temperature->{min} < 0;

    my $wind = $period->wind;
    return "wind" if $wind->{hours} > 4;

    return "";
}


1;
