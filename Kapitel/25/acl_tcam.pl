#!/usr/bin/perl

# Skript gibt Warnung, wenn eine Ressource im TCAM oberhalb dieser
# Schwelle liegt (Angabe in Prozent)
my $WARNING_IF_ABOVE_PERCENT = 30;

use Sys::Syslog qw( openlog closelog syslog );
openlog( $name, "ndelay,pid", "local0" );

# Ausgabe für SNMP-Daemon
my ( $CMD, $OID ) = @ARGV;
print "$OID\n".
  "integer\n";

if ( -e '/etc/cumulus/.license.vx' ) {
  # Virtueller Switch (Cumulus VX): Nichts machen

} else {
  # Physikalischer Switch: Ressourcen auswerten
  @acl_nutzung=`/usr/cumulus/bin/cl-resource-query | grep "% of"`;

  for my $ressource ( @acl_nutzung ) {
    if ( $ressource =~ /,\s+(\d+)\% of maximum value/ ) {
      my $prozent = $1;
      chomp $ressource;

      if ( $prozent > $WARNING_IF_ABOVE_PERCENT ) {
        $ressource =~ s/\s+/ /g;  # whitespace entfernen
        syslog( LOG_INFO, sprintf "Eintrag ueber Schwellwert (%d%%): %s",
          $WARNING_IF_ABOVE_PERCENT, $ressource );
        print "1";
        last;   # for-Schleife verlassen
      }
    }
  }
}

closelog();
exit( 0 );
