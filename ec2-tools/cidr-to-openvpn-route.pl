#!/usr/bin/env perl

=pod

 SUMMARY: A simple tool to convert subnet syntax from CIDR to OpenVPN route.

 LICENSE: released to public domain.

 AUTHOR: William Yeh <william.pjyeh@gmail.com>

 DATE: 2014-09-18

 GIST: https://gist.github.com/William-Yeh/9c9e07fbe959ccbb8784

=cut



main();


sub main
{
    while (my $line = <STDIN>) {
        chomp $line;
        my $result = convert($line);
        print $result, "\n";
    }
}


sub convert
{
    my ($line) = @_;

    if ($line !~ /^([^\/]+)\/(\d+)$/) {
        return $line;
    }

    my ($ip, $prefix) = ($1, $2);
    #print STDERR $ip, "\t", $prefix, "\n";

    my $netmask_binary = ('1' x $prefix) . ('0' x (32 - $prefix));
    #print STDERR $netmask_binary, "\n";

    my $netmask = convert_ip_from_bin_to_dotted_decimal($netmask_binary);
    #print STDERR $netmask, "\n";

    my $result = 'push "route '  . $ip . '  ' . $netmask . '"';
    return $result;
}



sub convert_ip_from_bin_to_dotted_decimal
{
    my ($input) = @_;
    my @ip_parts = ();

    foreach my $i ( (0, 8, 16, 24) ) {
        my $num_bin = substr($input, $i, 8);
        my $num     = bin_to_dec($num_bin);
        push(@ip_parts, $num);
    }

    return join('.', @ip_parts);
}


#
# convert a binary string to a number
# @see http://stackoverflow.com/a/483708
#
sub bin_to_dec
{
    my ($x_bin) = @_;
    return oct("0b" . $x_bin);
}
