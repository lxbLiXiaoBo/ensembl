use lib 't';

use strict;
use warnings;

use Bio::EnsEMBL::DensityType;
use Bio::EnsEMBL::Analysis;
use MultiTestDB;

use TestUtils qw(debug test_getter_setter);

our $verbose = 0; #set to 1 to turn on debug printouts



BEGIN { $| = 1;
	use Test;
	plan tests => 9;
}

use TestUtils qw( debug );



my $analysis = Bio::EnsEMBL::Analysis->new
  (-program     => "test",
   -database    => "ensembl",
   -gff_source  => "densityFeature.t",
   -gff_feature => "density",
   -logic_name  => "GeneDensityTest");


#
# test constructor
#
my $dt = Bio::EnsEMBL::DensityType->new
  (-dbID       => 1200,
   -analysis   => $analysis,
   -block_size => 600,
   -value_type => 'sum');

ok($dt && ref($dt) && $dt->isa('Bio::EnsEMBL::DensityType'));
ok($dt->dbID == 1200);
ok($dt->analysis == $analysis);
ok($dt->block_size == 600);
ok($dt->value_type eq 'sum');


#
# test getter/setter methods
#
ok(&test_getter_setter($dt, 'dbID', 12));
ok(&test_getter_setter($dt, 'analysis', undef));
ok(&test_getter_setter($dt, 'block_size', 300));
ok(&test_getter_setter($dt, 'value_type', 'ratio'));

