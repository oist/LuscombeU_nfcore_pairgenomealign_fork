/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { ASSEMBLYSCAN                     } from '../modules/nf-core/assemblyscan/main'
include { LAST_MAFCONVERT as ALIGNMENT_CRAM} from '../modules/nf-core/last/mafconvert/main'
include { LAST_MAFCONVERT as ALIGNMENT_EXP } from '../modules/nf-core/last/mafconvert/main'
include { SAMTOOLS_MERGE as ALIGNMENT_MERGE} from '../modules/nf-core/samtools/merge/main'
include { LAST_DOTPLOT as MULTIQC_THUMBS   } from '../modules/nf-core/last/dotplot/main'
include { MULTIQC_THUMBS_HTML              } from '../modules/local/multiqc_thumbs_html/main'
include { MULTIQC_ASSEMBLYSCAN_PLOT_DATA   } from '../modules/local/multiqc_assemblyscan_plot_data/main'
include { PAIRALIGN_M2M                    } from '../subworkflows/local/pairalign_m2m/main'
include { SEQTK_CUTN as CUTN_TARGET        } from '../modules/nf-core/seqtk/cutn/main'
include { SEQTK_CUTN as CUTN_QUERY         } from '../modules/nf-core/seqtk/cutn/main'
include { PAIRALIGN_M2O                    } from '../subworkflows/local/pairalign_m2o/main'
include { MULTIQC                          } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap                 } from 'plugin/nf-schema'
include { paramsSummaryMultiqc             } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML           } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { FASTA_BGZIP_INDEX_DICT_SAMTOOLS  } from '../subworkflows/local/fasta_bgzip_index_dict_samtools'
include { methodsDescriptionText           } from '../subworkflows/local/utils_nfcore_pairgenomealign_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PAIRGENOMEALIGN {

    take:
    ch_samplesheet  // channel: samplesheet read in from --input
    multiqc_config
    multiqc_logo
    multiqc_methods_description
    outdir
    ch_targetgenome // channel: genome file read in from --target

    main:

    def ch_versions = channel.empty()
    def ch_multiqc_files = channel.empty()

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
        assemblyscan_sorted_json_files = ASSEMBLYSCAN.out.report
          .toSortedList { a, b -> a[0].id <=> b[0].id }
          .map { sorted_list -> sorted_list.collect { it[1] } }
        // Sorted intput is needed for stable MD5 output
        MULTIQC_ASSEMBLYSCAN_PLOT_DATA ( assemblyscan_sorted_json_files )
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

    export_formats = params.export_aln_to.tokenize(',')
    if (params.multi_cram | export_formats.contains('cram') | export_formats.contains('bam')) {
        FASTA_BGZIP_INDEX_DICT_SAMTOOLS( ch_targetgenome )
        ch_genome_for_cram = FASTA_BGZIP_INDEX_DICT_SAMTOOLS.out.fasta_fai_gzi_dict.first()
    } else {
        ch_genome_for_cram = channel.value( [[:], [], [], [], []] )
    }
ch_targetgenome = ch_genome_for_cram
  .first()
  .multiMap { meta, fasta, fai, gzi, dict -> 
      fasta: [meta,fasta]
      fai: [meta,fai]
      gzi: [meta,gzi]
      dict: [meta,dict
   }
    if (!(params.export_aln_to == "no_export")) {
        ALIGNMENT_EXP(
            pairalign_out.o2o.combine(Channel.fromList(export_formats)),
            ch_genome_for_cram.map { meta, fasta, fai, gzi, dict -> [meta, fasta] },
            ch_genome_for_cram.map { meta, fasta, fai, gzi, dict -> [meta, fai]   },
            ch_genome_for_cram.map { meta, fasta, fai, gzi, dict -> [meta, gzi]   },
            ch_genome_for_cram.map { meta, fasta, fai, gzi, dict -> [meta, dict]  }
        )
    }

    if (params.multi_cram) {
        // We want the read group IDs to be just the query genome name (which is already long enough).
        o2o_alignments = pairalign_out.o2o.map { meta, alns ->
            def newMeta = meta.clone()    // Avoids unexpected propagation to pairalign_out.o2o's meta.id.
            newMeta.id = newMeta.id.replaceAll(/^.*___/, '')
            [newMeta, alns]
        }
        ALIGNMENT_CRAM(
            o2o_alignments.map {it + "cram"},
            ch_genome_for_cram.map { meta, fasta, fai, gzi, dict -> [meta, fasta] },
            ch_genome_for_cram.map { meta, fasta, fai, gzi, dict -> [meta, fai]   },
            ch_genome_for_cram.map { meta, fasta, fai, gzi, dict -> [meta, gzi]   },
            ch_genome_for_cram.map { meta, fasta, fai, gzi, dict -> [meta, dict]  }
        )
        // Collect all per-query CRAMs into a single merged CRAM per target genome
        ch_merge_input = ALIGNMENT_CRAM.out.alignment
            // Rename and use as grouping key
            .map { meta, cram -> tuple(params.targetName, cram) }
            // group all CRAMs
            .groupTuple()
            // convert to SAMTOOLS_MERGE input format
            .map { id, crams -> tuple([id: id], crams, []) }
        // Output a single CRAM file under the target genome name.
        ALIGNMENT_MERGE(
            ch_merge_input,
            FASTA_BGZIP_INDEX_DICT_SAMTOOLS.out.fasta_fai_gzi_dict.map { meta, fasta, fai, gzi, dict -> [meta, fasta, fai, gzi] }
        )
    }

    if (params.multiqc_thumbs != 0) {
        MULTIQC_THUMBS(
            pairalign_out.o2o.map { x -> [x[0], x[1], []] },
            [[],[]],
            "png",
            params.dotplot_filter
        )
        MULTIQC_THUMBS_HTML(
            MULTIQC_THUMBS.out.plot
                .map { meta, file -> file }
                .collect(),
            params.multiqc_thumbs
        )
        ch_multiqc_files = ch_multiqc_files.mix(MULTIQC_THUMBS_HTML.out.html)
    }

    // Collate and save software versions
    //
    def topic_versions = channel.topic("versions")
        .distinct()
        .branch { entry ->
            versions_file: entry instanceof Path
            versions_tuple: true
        }

    def topic_versions_string = topic_versions.versions_tuple
        .map { process, tool, version ->
            [ process[process.lastIndexOf(':')+1..-1], "  ${tool}: ${version}" ]
        }
        .groupTuple(by:0)
        .map { process, tool_versions ->
            tool_versions.unique().sort()
            "${process}:\n${tool_versions.join('\n')}"
        }

    def ch_collated_versions = softwareVersionsToYAML(ch_versions.mix(topic_versions.versions_file))
        .mix(topic_versions_string)
        .collectFile(
            storeDir: "${outdir}/pipeline_info",
            name: 'nf_core_'  +  'pairgenomealign_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        )

    //
    // MODULE: MultiQC
    //
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    def ch_summary_params = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")
    def ch_workflow_summary = channel.value(paramsSummaryMultiqc(ch_summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    def ch_multiqc_custom_methods_description = multiqc_methods_description
        ? file(multiqc_methods_description, checkIfExists: true)
        : file("${projectDir}/assets/methods_description_template.yml", checkIfExists: true)
    def ch_methods_description = channel.value(methodsDescriptionText(ch_multiqc_custom_methods_description))
    ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml', sort: true))
    MULTIQC(
        ch_multiqc_files.flatten().collect().map { files ->
            [
                [id: 'pairgenomealign'],
                files,
                multiqc_config
                    ? file(multiqc_config, checkIfExists: true)
                    : file("${projectDir}/assets/multiqc_config.yml", checkIfExists: true),
                multiqc_logo ? file(multiqc_logo, checkIfExists: true) : [],
                [],
                [],
            ]
        }
    )
    emit:multiqc_report = MULTIQC.out.report.map { _meta, report -> [report] }.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
