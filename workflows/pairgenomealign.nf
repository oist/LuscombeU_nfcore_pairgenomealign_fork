/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { ASSEMBLYSCAN                     } from '../modules/nf-core/assemblyscan/main'
include { SAMTOOLS_BGZIP as ALIGNMENT_BGZ  } from '../modules/nf-core/samtools/bgzip/main'
include { SAMTOOLS_FAIDX as ALIGNMENT_FAI  } from '../modules/nf-core/samtools/faidx/main'
include { SAMTOOLS_MERGE as ALIGNMENT_MERGE} from '../modules/nf-core/samtools/merge/main'
include { LAST_MAFCONVERT as ALIGNMENT_EXP } from '../modules/nf-core/last/mafconvert/main'
include { MULTIQC_ASSEMBLYSCAN_PLOT_DATA   } from '../modules/local/multiqc_assemblyscan_plot_data/main'
include { PAIRALIGN_M2M                    } from '../subworkflows/local/pairalign_m2m/main'
include { SEQTK_CUTN as CUTN_TARGET        } from '../modules/nf-core/seqtk/cutn/main'
include { SEQTK_CUTN as CUTN_QUERY         } from '../modules/nf-core/seqtk/cutn/main'
include { PAIRALIGN_M2O                    } from '../subworkflows/local/pairalign_m2o/main'
include { MULTIQC                          } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap                 } from 'plugin/nf-schema'
include { paramsSummaryMultiqc             } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML           } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText           } from '../subworkflows/local/utils_nfcore_pairgenomealign_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PAIRGENOMEALIGN {

    take:
    ch_samplesheet  // channel: samplesheet read in from --input
    ch_targetgenome // channel: genome file read in from --target
    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    // Extract coordinates of poly-N regions; they are often contig boundaries in scaffolds
    //
    CUTN_TARGET (
        // Avoid file name conflicts when target genome is also in the list of queries
        ch_targetgenome.map { meta, file -> [ [id:'targetGenome'] , file ] }
    )
    CUTN_QUERY (
        ch_samplesheet
    )

    // Allow to skip statistics on contig length and GC content
    //
    if (! params.skip_assembly_qc ) {
        ASSEMBLYSCAN ( ch_samplesheet )
        ch_versions = ch_versions.mix(ASSEMBLYSCAN.out.versions)
        MULTIQC_ASSEMBLYSCAN_PLOT_DATA (
            ASSEMBLYSCAN.out.json.collect{it[1]}
        )
        ch_multiqc_files = ch_multiqc_files.mix(MULTIQC_ASSEMBLYSCAN_PLOT_DATA.out.tsv)
    }

    // Prefix query ids with target genome name before producing alignment files
    //
    ch_samplesheet = ch_samplesheet
        .map { row -> [ [id: params.targetName + '___' + row[0].id] , row.tail() ] }
    ch_seqtk_cutn_query = CUTN_QUERY.out.bed
        .map { row -> [ [id: params.targetName + '___' + row[0].id] , row.tail() ] }

    // Align with either the many-to-many or the many-to-one subworkflow
    // and collect the output under a fixed name
    //
    if (!(params.m2m)) {
        PAIRALIGN_M2O (
            ch_targetgenome,
            ch_samplesheet,
            CUTN_TARGET.out.bed,
            ch_seqtk_cutn_query
        )
        pairalign_out = PAIRALIGN_M2O.out
    } else {
        PAIRALIGN_M2M (
            ch_targetgenome,
            ch_samplesheet,
            CUTN_TARGET.out.bed,
            ch_seqtk_cutn_query
        )
        pairalign_out = PAIRALIGN_M2M.out
    }

    if (!(params.export_aln_to == "no_export")) {
        // If we export to CRAM we need a samtools index,
        // if we export to BAM the index is also nice to have,
        //  otherwise we need placeholders.
        ch_targetgenome_fa  = [[],[]]
        ch_targetgenome_fai = [[],[]]
        ch_targetgenome_gzi = [[],[]]

        if (params.export_aln_to.contains('cram') |params.export_aln_to.contains('bam')) {
            // Guarantee BGZIP compression
            ALIGNMENT_BGZ ( ch_targetgenome )
            ch_versions = ch_versions.mix(ALIGNMENT_BGZ.out.versions.first())
            ch_targetgenome_fa = ALIGNMENT_BGZ.out.fasta

            // Index BGZIP-compressed file
            ALIGNMENT_FAI (
                ch_targetgenome_fa,
                [[],[]],
                false
            )
            ch_versions = ch_versions.mix(ALIGNMENT_FAI.out.versions.first())
            ch_targetgenome_fai = ALIGNMENT_FAI.out.fai
            ch_targetgenome_gzi = ALIGNMENT_FAI.out.gzi
        }

        ALIGNMENT_EXP(
            pairalign_out.o2o. map {it + params.export_aln_to},
            ch_targetgenome_fa,
            ch_targetgenome_fai,
            ch_targetgenome_gzi
        )
    }

    if (params.cram) {
        ALIGNMENT_MERGE(
            ALIGNMENT_EXP.out.cram.map { it -> [[id:params.targetName], it[1]] }.groupTuple() ,
            [[],[]],
            [[],[]]
        )
    }

    // Collate and save software versions
    //

    ch_versions = ch_versions
        .mix( CUTN_TARGET.out.versions)
        .mix(   pairalign_out.versions)

    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'pairgenomealign_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    //
    // MODULE: MultiQC
    //
    ch_multiqc_config        = Channel.fromPath(
        "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ?
        Channel.fromPath(params.multiqc_config, checkIfExists: true) :
        Channel.empty()
    ch_multiqc_logo          = params.multiqc_logo ?
        Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
        Channel.empty()

    summary_params      = paramsSummaryMap(
        workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files
        .mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
        .mix(pairalign_out.multiqc)
        .mix(ch_collated_versions)
        .mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true
        )
    )

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList(),
        [],
        []
    )

    emit:multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
