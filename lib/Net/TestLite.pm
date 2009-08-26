package Net::TestLite;

use 5.010000;
use strict;
use warnings;

use Net::DNS::Check;
use Net::DNS::Check::Config;
use Socket;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Net::TestLite ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Preloaded methods go here.

# ACCESSABLE SUBS
sub new {
    my $package = shift;
    return bless({}, $package);
}	# ----------  end of subroutine new  ----------


sub auth {
    my $self = shift;
    my $res = {};

    foreach my $url (@_) {
        #next unless is_url($url);
        $res->{$url}-

}   # ----------  end of subroutine auth  ----------

sub echo {
    my $self = shift;
    if (@_) {
        return dolc( join("",@_) );
    } else {
        return;
    }
}	# ----------  end of subroutine echo  ----------

#   INTERNAL SUBS

sub dolc {
    my $query = shift;
    $query = lc $query; 
	return $query;
}	# ----------  end of subroutine dolc  ----------


sub is_url {
	my	( $par1 )	= @_;
    #
    #   This will verify urls
    #
	return ;
}	# ----------  end of subroutine is_url  ----------

sub get_authority {
	my	( $host, $dns )	= @_;
    my  $res = {};  # responce

    $dns = "192.5.6.30" unless $dns; # default to a.root-servers.net if no ns given


    my	$dig_command = " dig $host \@$dns |";		# pipe command

    open  my $dig, $dig_command
    or die  "$0 : failed to open  pipe '$dig_command' : $!\n";

    while(<$dig>){
        $res->{'text'} .= $_;
    }

    close  $dig
        or warn "$0 : failed to close pipe '$dig_command' : $!\n";

	return ;
}	# ----------  end of subroutine get_authority  ----------

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
