#!/usr/bin/perl

# Zugriff auf die Cumulus-API mit Perl
# Tested and working on CentOS 6

use REST::Client;   # yum install perl-REST-Client (see rev 1.1)
use JSON;           # yum install perl-JSON
use MIME::Base64;

my $client = REST::Client->new();
$client->setHost('https://10.5.1.1:8080');

# Authentifizierung
my $user = 'apiuser';
my $pass = 'apipass';


# Beispiel fuer API-Zugriff mit GET-Anfrage
$client->GET( '/', {
  Authorization => 'Basic ' . encode_base64("$user:$pass")
});

# Unstrukturierte Ausgabe
print $client->responseContent();

# Strukturierte Ausgabe
my $response = from_json( $client->responseContent() );
printf "API-Version: %s-%s\n",
  $response->{'version'}->{'api_version'},
  $response->{'version'}->{'api_status'};


# Beispiel fuer API-Zugriff mit POST-Anfrage
$client->POST( '/nclu/v1/rpc',
  '{ "cmd":"show version" }', {
  'Content-Type'  => 'application/json',
  'Authorization' => 'Basic ' . encode_base64("$user:$pass")
});
print "Response Code: " . $client->responseCode() . "\n";
print "Response Content\n" . $client->responseContent() . "\n";
