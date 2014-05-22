#!/usr/bin/env perl
=pod

 SUMMARY: A simple tool to query the IP ranges for GCE zones.

 REFERENCE: http://stackoverflow.com/a/19434481 

 LICENSE: released to public domain.

 AUTHOR:  William Yeh <william.pjyeh@gmail.com>

 DATE: 2014-05-22

 GIST: https://gist.github.com/William-Yeh/32cd212c62ad4c95b11f

=cut


my $DIG_CMD     = 'dig txt +short';
my $INITIAL_URL = '_cloud-netblocks.googleusercontent.com'; 

main();


sub main
{
    find_ip_range($INITIAL_URL);
}


sub find_ip_range
{
    my ($url) = @_;
    my $cmd = $DIG_CMD . ' ' . $url;

    my $dig_output = `$cmd`;
    #print STDERR $dig_output;

    my @result = extract_include($dig_output);
    #print STDERR "@result", "\n";

    if (scalar @result > 0) {
        foreach my $next_level_url (@result) {
            find_ip_range($next_level_url);
        }
    }
    else {
        my @ip_values = extract_ip($dig_output);
        foreach my $ip (@ip_values) {
            print $ip, "\n";
        }
    }
}


#
# extract "include:" record
#
# e.g., "v=spf1 include:_cloud-netblocks1.googleusercontent.com include:_cloud-netblocks2.googleusercontent.com include:_cloud-netblocks3.googleusercontent.com ?all"
#
sub extract_include
{
    my ($txt) = @_;
    my @result = ();

    my @records = split(/\s+/, $txt);
    foreach my $item (@records) {
        if ($item =~ /^include\:([^\s]+)/) {
            push(@result, $1);
        }
    }

    return @result;
}


#
# extract "ip4:" record
#
# e.g., "v=spf1 ip4:8.34.208.0/20 ip4:8.35.192.0/21 ip4:8.35.200.0/23 ip4:108.59.80.0/20 ip4:108.170.192.0/20 ip4:108.170.208.0/21 ip4:108.170.216.0/22 ip4:108.170.220.0/23 ip4:108.170.222.0/24 ?all"
#
sub extract_ip
{
    my ($txt) = @_;
    my @result = ();

    my @records = split(/\s+/, $txt);
    foreach my $item (@records) {
        if ($item =~ /^ip4\:([^\s]+)/) {
            push(@result, $1);
        }
    }

    return @result;
}
