package Gene;

use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBUtils;
use Try::Tiny;

prepare_serializer_for_format;

#curl http://localhost:3000/Gene/Human/Name/ACE.json
get '/Gene/:species/Name/:gene.:format' => sub {
	my $species = params->{species};
	my $gene    = params->{gene};

	getResult( $species, $gene, 1 );
};

#curl http://localhost:3000/Gene/Human/Id/ENSG00000159640.json
get '/Gene/:species/Id/:id.:format' => sub {
	my $species = params->{species};
	my $id      = params->{id};

	getResult( $species, $id, 0 );
};

sub getResult {
	my $species = shift;
	my $input   = shift;
	my $isName  = shift;

	my $registry;
	if ( lc($species) eq "human" || lc($species) eq "mouse" || lc($species) eq "rat" || lc($species) eq "horse" ) {
		$registry = DBUtils::GetRegistry();
	}
	else {
		$registry = DBUtils::GetEnsemblRegistry();
	}

	try {
		my $gene_adaptor = $registry->get_adaptor( $species, "Core", "Gene" );
		if ($isName) {
			my $gene_results = [];
			foreach my $gene ( @{ $gene_adaptor->fetch_all_by_external_name($input) } ) {
				push( @$gene_results, getGene($gene) );
			}

			status_ok($gene_results);
		}
		else {
			status_ok( getGene( $gene_adaptor->fetch_by_stable_id($input) ) );
		}
	  }
	  catch {
		status_bad_request($_);
	  }
	  finally {
		$registry->clear();
	  };
}

sub getGene {
	my $gene = shift;

	my $transcript_results = [];
	foreach my $transcript ( @{ $gene->get_all_Transcripts() } ) {
		my $exon_results = [];
		foreach my $exon ( @{ $transcript->get_all_Exons() } ) {
			my $exon_result = {
				id         => $exon->stable_id(),
				chromosome => $exon->slice()->seq_region_name(),
				start      => $exon->start(),
				end        => $exon->end(),
				strand     => $exon->strand(),
				sequence   => $exon->seq()->seq()
			};
			push( @$exon_results, $exon_result );
		}

		my $transcript_result = {
			id         => $transcript->stable_id(),
			chromosome => $transcript->slice()->seq_region_name(),
			start      => $transcript->start(),
			end        => $transcript->end(),
			strand     => $transcript->strand(),
			exons      => $exon_results
		};
		push( @$transcript_results, $transcript_result );
	}

	my $gene_result = {
		id          => $gene->stable_id(),
		chromosome  => $gene->slice()->seq_region_name(),
		start       => $gene->start(),
		end         => $gene->end(),
		strand      => $gene->strand(),
		description => $gene->description(),
		transcripts => $transcript_results
	};

	return $gene_result;
}

true;
