#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/pairgenomealign
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/pairgenomealign
    Website: https://nf-co.re/pairgenomealign
    Slack  : https://nfcore.slack.com/channels/pairgenomealign
----------------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { PAIRGENOMEALIGN  } from './workflows/pairgenomealign'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_pairgenomealign_pipeline'
include { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_pairgenomealign_pipeline'
include { getGenomeAttribute      } from './subworkflows/local/utils_nfcore_pairgenomealign_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//   This is an example of how to use getGenomeAttribute() to fetch parameters
//   from igenomes.config using `--genome`
params.fasta = getGenomeAttribute('fasta')

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow NFCORE_PAIRGENOMEALIGN {

    take:
    samplesheet // channel: samplesheet read in from --input
    target_genome // channel: genome file read in from --target

    main:

    //
    // WORKFLOW: Run pipeline
    //
    PAIRGENOMEALIGN (
        samplesheet,
        params.multiqc_config,
        params.multiqc_logo,
        params.multiqc_methods_description,
        params.outdir,
        target_genome
    )
    emit:
    multiqc_report = PAIRGENOMEALIGN.out.multiqc_report // channel: /path/to/multiqc_report.html
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:
    // Validate mutually exclusive parameters
    if (params.input && params.query) {
        error """
        ❌ Invalid parameter combination

        You provided both:
          --input  (sample sheet)
          --query  (single genome)

        These options are mutually exclusive.

        👉 Use only one:
           • --input : for multiple samples via a sample sheet
           • --query : for a single query genome (no sample sheet required)
        """
    }
    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.input,
        params.help,
        params.help_full,
        params.show_hidden
    )

    channel
        .value( params.target )
        .map { filename -> file(filename, checkIfExists: true) }
        .map { file_obj -> [ [id:params.targetName], file_obj] }
        .set { ch_target }

    if ( params.query ) {
        channel
            .value( params.query )
            .map { filename -> file(filename, checkIfExists: true) }
            .map { file_obj -> [ [id:params.queryName],  file_obj] }
            .set { ch_query }
    } else {
        ch_query = PIPELINE_INITIALISATION.out.samplesheet
    }

    //
    // WORKFLOW: Run main workflow
    //
    NFCORE_PAIRGENOMEALIGN (
        ch_query,
        ch_target
    )
    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        NFCORE_PAIRGENOMEALIGN.out.multiqc_report
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
