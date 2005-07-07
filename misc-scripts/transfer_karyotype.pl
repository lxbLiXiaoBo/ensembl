# Transfer karyotype data from old -> new database, scaling appropriately.

use strict;

use DBI;
use Getopt::Long;

my ( $oldhost, $olduser, $oldpass, $oldport, $olddbname, $newhost, $newuser, $newpass, $newport, $newdbname  );


GetOptions( "oldhost=s",   \$oldhost,
	    "olduser=s",   \$olduser,
	    "oldpass=s",   \$oldpass,
	    "oldport=i",   \$oldport,
	    "olddbname=s", \$olddbname,
	    "newhost=s",   \$newhost,
	    "newuser=s",   \$newuser,
	    "newpass=s",   \$newpass,
	    "newport=i",   \$newport,
	    "newdbname=s", \$newdbname);

usage() if (!$oldhost);

my $old_db = DBI->connect("DBI:mysql:host=$oldhost;dbname=$olddbname;port=$oldport", $olduser, $oldpass);

my $new_db = DBI->connect("DBI:mysql:host=$newhost;dbname=$newdbname;port=$newport", $newuser, $newpass);

my $old_sth = $old_db->prepare("SELECT sr.name, cs.name, sr.length, k.seq_region_start, k.seq_region_end, k.band, k.stain FROM seq_region sr, coord_system cs, karyotype k WHERE sr.coord_system_id=cs.coord_system_id AND sr.seq_region_id=k.seq_region_id");
$old_sth->execute();

my ($old_sr_name, $old_cs_name, $old_sr_length, $old_k_start, $old_k_end, $band, $stain);
$old_sth->bind_columns(\$old_sr_name, \$old_cs_name, \$old_sr_length, \$old_k_start, \$old_k_end, \$band, \$stain);

my $new_sth = $new_db->prepare("SELECT sr.seq_region_id, sr.length FROM seq_region sr, coord_system cs WHERE sr.name=? and cs.name=? AND sr.coord_system_id=cs.coord_system_id");
my ($new_sr_id, $new_sr_length);

my $insert_sth = $new_db->prepare("INSERT INTO karyotype (seq_region_id, seq_region_start, seq_region_end, band, stain) VALUES(?,?,?,?,?)");

my $count;

while ($old_sth->fetch()) {

  # get matching seq region from new database & calculate scaling factor
  $new_sth->execute($old_sr_name, $old_cs_name);
  $new_sth->bind_columns(\$new_sr_id, \$new_sr_length);
  my $scale_factor;
  if ($new_sth->fetch()) {

    $scale_factor = ($new_sr_length/$old_sr_length);
    my $new_k_start = int($old_k_start * $scale_factor) || 1;
    my $new_k_end = int($old_k_end * $scale_factor);

    # Add new entry to new karyotype table
    $insert_sth->execute($new_sr_id, $new_k_start, $new_k_end, $band, $stain) || die "Error inserting into new karyotype table";
    $count++;

  } else {
    warn("Can't get new seq_region ID corresponding to $old_cs_name:$old_sr_name\n");
  }

}

print "Inserted $count rows into $newdbname.karyotype\n";


sub usage {

  print<<EOF;
Transfer karyotype data from old to new database, scaling appropriately.

perl transfer_karyotype.pl -oldhost ... -olduser ... -oldpass ... -oldport ... -olddbname ... -newhost ... -newuser ... -newpass ... -newport ... -newdbname

EOF

  exit(1);

}
