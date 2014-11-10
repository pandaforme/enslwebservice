package Info;

use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBUtils;

use Bio::EnsEMBL::ApiVersion;

prepare_serializer_for_format;

#curl http://localhost:3000/Info/Software.json
get '/Info/Software.:format' => sub {
	my $result = { release => software_version() };
	status_ok($result);
};

#curl http://localhost:3000/Info/Species.json
get '/Info/Species.:format' => sub {
	my $registry = DBUtils::GetRegistry();
	my $results = [];

	foreach my $db_adaptor ( @{ $registry->get_all_DBAdaptors() } ) {
		my $species = $db_adaptor->species();

		my $aliases = [];
		foreach my $aliase ( @{ $registry->get_all_aliases($species) } ) {
			push( @$aliases, $aliase );
		}

		my $result = {
			species => $species,
			aliases => $aliases
		};
		
		push( @$results, $result );
	}
		
	status_ok($results);
};

true;
