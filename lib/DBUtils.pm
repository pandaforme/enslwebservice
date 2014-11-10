package DBUtils;

use Dancer ':syntax';
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

sub GetRegistry() {
	$registry->load_registry_from_db(
		-host => config->{db_host},
		-user => config->{db_user},
		-pass => config->{db_pass},
		-port => config->{db_port}
	);

	return $registry;
}

sub GetEnsemblRegistry() {
	$registry->load_registry_from_db(
		-host => config->{ensembl_db_host},
		-user => config->{ensembl_db_user},
		-pass => config->{ensembl_db_pass},
		-port => config->{ensembl_db_port}
	);

	return $registry;
}

true;
