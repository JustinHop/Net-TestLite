package Net::TestLite;

use 5.010000;
use strict;
use warnings;

use Net::HTTP;
use Net::DNS::Check;
use Net::DNS::Check::Config;
use Data::Dumper;
use Socket;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Net::TestLite ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [qw( )] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( );

our $VERSION = '0.01';

#
#   Local Module Variables
#       Probably the wrong way to do this but w/e
#
my @LOCAL_NS = ( "ns1.umusic.com", "ns2.umusic.com", "ns5.umusic.com" );
my @GTLD_NS = (
    "A.GTLD-SERVERS.NET", "B.GTLD-SERVERS.NET",
    "C.GTLD-SERVERS.NET", "D.GTLD-SERVERS.NET",
    "E.GTLD-SERVERS.NET", "F.GTLD-SERVERS.NET",
    "G.GTLD-SERVERS.NET", "H.GTLD-SERVERS.NET",
    "I.GTLD-SERVERS.NET",
);

my @IGA = (
    "172.25.26.10", "172.25.26.11", "172.25.26.12", "172.25.26.13",
    "172.25.26.14", "172.25.26.15"
);

my @SHARED = ( "172.25.26.19", "172.25.26.20", "172.25.26.21", );
my @IDJ    = ( "172.25.26.6",  "172.25.26.7",  "172.25.26.8", "172.25.26.9", );
my @UMRG   = ( "172.25.26.16", "172.25.26.17", "172.25.26.18", );
my @LINUX  = ( "172.25.26.2",  "172.25.26.3",  "172.25.26.4", "172.25.26.5" );

my $debug = 1;

# Preloaded methods go here.

# ACCESSABLE SUBS
sub new {
    my $package = shift;
    warn a_gtld_server();
    return bless( {}, $package );
}    # ----------  end of subroutine new  ----------

sub in_ptr {
    my $self  = shift;
    my $query = shift;
    return unless is_url($query);
    my $res = dig($query);

    #warn Dumper($res);
    return $res->{'answer'}[0]->{'value'};
}    # ----------  end of subroutine in_a  ----------

sub umg_ns {

    my $self  = shift;
    my $query = shift;
    return unless is_url($query);
    my $res = {};

    foreach my $ns (@LOCAL_NS) {

        #warn "\$ns = $ns";
        my $dig = dig( $query, $ns );
        $res->{$ns} = $dig->{'answer'}[0]->{'value'};
    }

    return $res;
}    # ----------  end of subroutine umg_ns  ----------

sub auth_string {
    chomp;
    my $self  = shift;
    my $query = shift;
    return unless is_url($query);
    my $res = "";

    my $dig = dig( $query, a_gtld_server() );

    foreach ( @{ $dig->{'authority'} } ) {
        my $sep = "";
        $sep = " " if ( $res !~ /^$/ );

        $res .= $sep . $_->{'value'};
    }
    return $res;
}    # ----------  end of subroutine auth_string  ----------

sub auth {

    chomp;
    my $self = shift;
    my $res  = {};

    foreach (@_) {
        my $url = $_;

        #next unless is_url($url);
        $res->{$url} = dig( $url, a_gtld_server() );
    }

    return $res;
}    # ----------  end of subroutine auth  ----------

sub http {
    my $self = shift;
    my ( $query, $host ) = @_;
    my $res = {};
    return unless is_url($query);
    if ($host) {
        return unless is_host($host);
        $res = http_req( $query, $host );
    } else {
        $res = http_req($query);
    }

    return $res;
}    # ----------  end of subroutine http  ----------

sub http_cluster {
    my $self = shift;
    my ( $query, $cluster ) = @_;
    return unless is_url($query);
    my ( @cluster, $res );
    if ( $cluster =~ /(iga|interscope)/i ) {
        @cluster = @IGA;
    } elsif ( $cluster =~ /idj/i ) {
        @cluster = @IDJ;
    } elsif ( $cluster =~ /umrg/i ) {
        @cluster = @UMRG;
    } elsif ( $cluster =~ /linux/i ) {
        @cluster = @LINUX;
    } else {
        @cluster = @SHARED;
    }

    for (@cluster) {
        my $host = $_;
        $res->{$_} = http_req( $query, $host );
    }

    return $res;
}    # ----------  end of subroutine http_cluster  ----------

#   INTERNAL SUBS
sub http_req {
    my ( $query, $host ) = @_;
    my $res = {};
    my %h;
    $res->{'head'} = {};

    my $s;

    if ($host) {
        $s = Net::HTTP->new( Host => $query, PeerAddr => $host ) || die $@;
    } else {
        $s = Net::HTTP->new( Host => $query ) || die $@;
    }

    $s->write_request( GET => "/", 'User-Agent' => "Mozilla/5.0" );
    ( $res->{'code'}, $res->{'mess'}, %h ) = $s->read_response_headers;

    for ( keys(%h) ) {
        $res->{'head'}->{$_} = $h{$_};
    }

    while (1) {
        my $buf;
        my $n = $s->read_entity_body( $buf, 1024 );
        die "read failed: $!" unless defined $n;
        last unless $n;
        $res->{'body'} .= $buf;
    }

    return $res;
}    # ----------  end of subroutine http_req  ----------

sub is_host {
    my ($par1) = @_;
    return 1;
}    # ----------  end of subroutine is_host  ----------

sub is_url {

    #warn "is_url is a stub";
    my ($par1) = @_;

    #
    #   This will verify urls
    #
    return 1;
}    # ----------  end of subroutine is_url  ----------

sub a_gtld_server {
    my $i = $#GTLD_NS + 1;
    $i = int rand($i);
    return $GTLD_NS[$i];
}    # ----------  end of subroutine a_gtld_server  ----------

sub a_root_server {

    my $dig = dig();

    #warn Dumper($dig->{'additional'}[0]->{'value'});

    return $dig->{'additional'}[0]->{'value'};
}    # ----------  end of subroutine a_root_server  ----------

sub dig {

    my ( $host, $dns ) = @_;
    my $debug = 0;
    warn "dig($host,$dns)" if $debug and $dns;
    my $res = {};    # responce

    my $dig_command = 'dig ';
    $dig_command .= $host . ' '      if $host;
    $dig_command .= '@' . $dns . " " if $dns;
    $dig_command .= ' any |';

    warn $dig_command if $debug;
    open my $dig, $dig_command
      or die "$0 : failed to open  pipe '$dig_command' : $!\n";

    my $section = "";
    while (<$dig>) {
        $res->{'text'} .= $_;
        if (/;; (\w+) SECTION:/) {
            $section = lc $1;
        }
        if (/(\S+)\s+(\d+)\s+(\w+)\s+(\w+)\s+(\S+)/) {
            push(
                @{ $res->{$section} },
                {
                    record => $1,
                    ttl    => $2,
                    in     => $4,
                    value  => $5,
                }
            );
        }
    }

    close $dig
      or warn "$0 : failed to close pipe '$dig_command' : $!\n";
    warn Dumper($res) if $debug;
    return $res;
}    # ----------  end of subroutine dig  ----------

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Net::TestLite - Automate my network tests 

=head1 SYNOPSIS

  use Net::TestLite;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Net::TestLite, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited....  or was he? 

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Justin Hoppensteadt, E<lt>justin@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Justin Hoppensteadt

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
