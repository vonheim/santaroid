package Santaroid::Weather::Period;

# Perform filtering and aggregations on a set of YR.no <time/> nodes

use Moose;
use DateTime::Format::DateParse;
use List::Util;


has 'time_nodes' => (is=>'rw', required=>1);


sub rain {
    my ($self) = @_;

    my @rain = ();
    $self->time_by_duration(1)->time_nodes->each(sub {
        if( my $rain = $_->at('precipitation[unit="mm"]') ) {
            push @rain, $rain->{value};
        }
    });
    @rain = (0) if @rain==0;

    return {
        max => List::Util::max(@rain),
        min => List::Util::min(@rain),
        avg => List::Util::sum(@rain) / @rain,
        sum => List::Util::sum(@rain),
        hours => scalar grep {$_ != 0} @rain,
    };
}


sub temperature {
    my ($self) = @_;

    my @temps = ();
    $self->time_by_duration(0)->time_nodes->each(sub {
        if( my $temp = $_->at('temperature[unit="celsius"]') ) {
            push @temps, $temp->{value};
        }
    });

    return {
        max => List::Util::max(@temps),
        min => List::Util::min(@temps),
        avg => List::Util::sum(@temps) / @temps,
    };
}


sub wind {
    my ($self) = @_;

    my @wind = ();
    $self->time_by_duration(0)->time_nodes->each(sub {
        if( my $wind = $_->at('windspeed') ) {
            push @wind, $wind->{mps};
        }
    });

    return {
        max => List::Util::max(@wind),
        min => List::Util::min(@wind),
        avg => List::Util::sum(@wind) / @wind,
        hours => scalar grep {$_ > 5.5} @wind,
    };
}


sub time_slice {
    my ($self, $start, $finish) = @_;

    my $time_nodes = $self->time_nodes->grep(sub {
        my $time = $self->_time_info($_);
        return ($time->{from}>=$start) && ($time->{from} < $finish);
    });
    return Santaroid::Weather::Period->new(time_nodes=>$time_nodes);
}


sub time_by_duration {
    my ($self, $hours) = @_;

    my $time_nodes = $self->time_nodes->grep(sub {
        return $self->_time_info($_)->{span_in_hours} == $hours;
    });
    return Santaroid::Weather::Period->new(time_nodes=>$time_nodes);
}


sub next_n_hours {
    my ($self, $hours) = @_;

    my $start  = DateTime->now;
    my $finish = $start->clone->add(hours=>$hours);
    return $self->time_slice($start, $finish);
}


sub _time_info {
    my ($self, $node) = @_;
    my $time = {
        from => DateTime::Format::DateParse->parse_datetime($node->{from}),
        to   => DateTime::Format::DateParse->parse_datetime($node->{to}),
    };

    my $diff = $time->{to}->subtract_datetime($time->{from});
    $time->{span_in_hours} = $diff->hours;
    return $time;
}


1;
