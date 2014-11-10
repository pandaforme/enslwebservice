package Sequence;

use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBUtils;
use Try::Tiny;

prepare_serializer_for_format;

#curl http://localhost:3000/Sequence/human/17/61552742/61554421/1.json
get '/Sequence/:species/:chromosome/:start/:end/:strand.:format' => sub {
	my $species    = params->{species};
	my $chromosome = params->{chromosome};
	my $start      = params->{start};
	my $end        = params->{end};
	my $strand     = params->{strand};

	my $registry;
	if ( lc($species) eq "human" || lc($species) eq "mouse" || lc($species) eq "rat" || lc($species) eq "horse" ) {
		$registry = DBUtils::GetRegistry();
	}
	else {
		$registry = DBUtils::GetEnsemblRegistry();
	}

	try {
		my $slice_adaptor = $registry->get_adaptor( $species, "Core", "Slice" );

		my $slice = $slice_adaptor->fetch_by_region( "chromosome", $chromosome, $start, $end, $strand );

		my $result = {
			chromosome => $slice->seq_region_name(),
			start      => $slice->start(),
			end        => $slice->end(),
			strand     => $slice->strand(),
			sequence   => $slice->seq()
		};

		status_ok($result);
	  }
	  catch{
	  	status_bad_request($_);
	  }
	  finally {
		$registry->clear();
	  };
};

true;
