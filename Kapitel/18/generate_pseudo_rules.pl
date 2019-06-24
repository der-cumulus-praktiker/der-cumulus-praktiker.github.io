#!/usr/bin/perl

# purpose: generate many ACL rules for Cumulus Linux

my $number_of_rules = shift || 10;

foreach my $c ( 1 .. $number_of_rules ) {
	printf(
		"net add acl ipv4 BENCH4 accept tcp ".
		"source-ip 192.0.2.%d/32 source-port %d ".
		"dest-ip any dest-port any\n",
			int( rand( 256 )),
			int( rand( 64511 )) + 1024
	);
}

exit( 0 );
