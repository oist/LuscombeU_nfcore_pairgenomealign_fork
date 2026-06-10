/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { LAST_LASTAL     as ALIGNMENT_LASTAL_M2O      } from '../../../modules/nf-core/last/lastal/main'
include { LAST_LASTDB     as ALIGNMENT_LASTDB          } from '../../../modules/nf-core/last/lastdb/main'
include { LAST_TRAIN      as ALIGNMENT_TRAIN           } from '../../../modules/nf-core/last/train/main'
include { LAST_MAFCONVERT as ALIGNMENT_READS           } from '../../../modules/nf-core/last/mafconvert/main'
include { FASTA_BGZIP_INDEX_DICT_SAMTOOLS              } from '../../../subworkflows/nf-core/fasta_bgzip_index_dict_samtools/main'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PAIRALIGN_READS {

    take:
    ch_target       // channel: target file read in from --target
    ch_queries      // channel: query sequences found in samplesheet read in from --input

    main:

    // Index the target genome

    ALIGNMENT_LASTDB ( ch_target )                  // for LAST
    FASTA_BGZIP_INDEX_DICT_SAMTOOLS ( ch_target )   // for Samtools
    ch_targetgenome = FASTA_BGZIP_INDEX_DICT_SAMTOOLS.out.fasta_fai_gzi_dict
        .first()
        .multiMap { meta, fasta, fai, gzi, _sizes, dict ->
            fasta: [meta, fasta]
            fai:   [meta, fai]
            gzi:   [meta, gzi]
            dict:  [meta, dict]
    }

    // Train alignment parameters if not provided

    if (params.lastal_params) {
        ch_queries_with_params = ch_queries.map { row -> [ row[0], row[1], file(params.lastal_params, checkIfExists: true) ] }
        training_results_for_multiqc = channel.empty()
    } else {
        ALIGNMENT_TRAIN (
            ch_queries,
            ALIGNMENT_LASTDB.out.index.map { row -> row[1] }  // Remove metadata map
        )
        ch_queries_with_params = ch_queries.join(ALIGNMENT_TRAIN.out.param_file)
        training_results_for_multiqc = ALIGNMENT_TRAIN.out.multiqc.collect{ it[1] }
    }

    // Align queries to target.

    ALIGNMENT_LASTAL_M2O (
        ch_queries_with_params,
        ALIGNMENT_LASTDB.out.index.map { row -> row[1] }  // Remove metadata map
    )

    ALIGNMENT_READS (
        ALIGNMENT_LASTAL_M2O.out.maf.combine(Channel.fromList(['cram'])),
        ch_targetgenome.fasta,
        ch_targetgenome.fai,
        ch_targetgenome.gzi,
        ch_targetgenome.dict
        )

    emit:

    multiqc = channel.empty().mix(training_results_for_multiqc)
    m2o     = ALIGNMENT_LASTAL_M2O.out.maf
    }
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
