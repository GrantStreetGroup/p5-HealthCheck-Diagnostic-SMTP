package HealthCheck::Diagnostic::SMTP;

use strict;
use warnings;

use parent 'HealthCheck::Diagnostic';

use Net::SMTP;

# https://metacpan.org/pod/distribution/perl/pod/perl5140delta.pod#Exception-Handling
use constant UNSTABLE_DOLLARAT => $] lt '5.013002';

# ABSTRACT: Verify connectivity to an SMTP mail server
# VERSION

sub new {
    my ($class, @params) = @_;

    my %params = @params == 1 && ( ref $params[0] || '' ) eq 'HASH'
        ? %{ $params[0] } : @params;

    return $class->SUPER::new(
        id     => 'smtp',
        label  => 'SMTP',
        %params,
    );
}

sub check {
    my ($self, %params) = @_;

    # Make it so that the diagnostic can be used as an instance or a
    # class, and the `check` params get preference.
    if ( ref $self ) {
        $params{ $_ } = $self->{ $_ }
            foreach grep { ! defined $params{ $_ } } keys %$self;
    }

    return $self->SUPER::check( %params );
}

sub run {
    my ($self, %params) = @_;

    local $@ unless UNSTABLE_DOLLARAT;
    my $smtp = $self->smtp_connect( %params );

    unless ( $smtp ) {
        return {
            status => 'CRITICAL',
            info   => "$@",
        };
    }

    my $banner = $smtp->banner;
    $smtp->quit;

    return {
        status => 'OK',
        info   => $banner,
    };
}

sub smtp_connect {
    my ( $self, %params ) = @_;

    my $host    = $params{ host } or die "host is required\n";
    my $port    = $params{ port }    // 25;
    my $timeout = $params{ timeout } // 5;

    $host = $host->( %params ) if ref $host eq 'CODE';

    return Net::SMTP->new( $host, Timeout => $timeout, Port => $port );
}

1;
__END__

=head1 SYNOPSIS

Check that you can talk to the server.

    my $health_check = HealthCheck->new( checks => [
        HealthCheck::Diagnostic::SMTP->new(
            host    => 'smtp.gmail.com',
            timeout => 5,
    ]);

=head1 DESCRIPTION

Determines if the SMTP mail server is available. Sets the C<status> to "OK" if
the connection was successful, or "CRITICAL" otherwise.

=head1 ATTRIBUTES

Can be passed either to C<new> or C<check>.

=head2 host

B<required> Either a string of the hostname or a coderef that returns a hostname
string.

=head2 port

The port to connect to. Defaults to 25.

=head2 timeout

The number of seconds to timeout after trying to establish a connection.
Defaults to 5.

=head1 DEPENDENCIES

L<HealthCheck::Diagnostic>
L<Net::SMTP>
