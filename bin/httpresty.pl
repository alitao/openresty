#!/usr/bin/env perl

use strict;
use warnings;

use lib '../../lib';
use utf8;
use JSON::XS;
use YAML 'Dump';
use WWW::OpenResty::Simple;
#use Date::Manip;
use Getopt::Std;
use Encode qw(encode decode from_to);

#$JSON::Syck::ImplicitUnicode = 1;
#$YAML::Syck::ImplicitUnicode = 1;
my $json_xs = JSON::XS->new->utf8->allow_nonref;

my %opts;
getopts('u:s:p:c:h', \%opts);
if ($opts{h}) {
    die "Usage: $0 -c <charset> -u <user> -p <password> -s <openresty_server> <http_method> <url>\n";
}
my $user = $opts{u} or
    die "No OpenResty account name specified via option -u\n";
my $password = $opts{p} or
    die "No OpenResty account's Admin password specified via option -p\n";
my $server = $opts{s} || 'http://api.openresty.org';

my $resty = WWW::OpenResty::Simple->new( { server => $server } );
$resty->login($user, $password);

my $meth = shift or
    die "No method specified.\n";
$meth = lc($meth);

my $url = shift or
    die "No url spcified.\n";
if ($opts{c}) {
    from_to($url, $opts{c}, 'utf8');
}

if (!$resty->can($meth)) {
    die "Method $meth not found.\n";
}

my $res = $resty->$meth($url);
my $out = Dump($res);
if ($opts{c}) {
    $out = encode($opts{c}, $out);
}
print $out, "\n";

