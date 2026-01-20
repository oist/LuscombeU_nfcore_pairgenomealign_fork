include { SAMTOOLS_BGZIP     } from '../../../modules/nf-core/samtools/bgzip/main'
include { SAMTOOLS_DICT      } from '../../../modules/nf-core/samtools/dict/main'
include { SAMTOOLS_FAIDX     } from '../../../modules/nf-core/samtools/faidx/main'

workflow FASTA_BGZIP_INDEX_DICT_SAMTOOLS {

    take:
    ch_fasta // channel: [ val(meta), fasta ]

    main:

    ch_versions = Channel.empty()

    // Guarantee BGZIP compression
    SAMTOOLS_BGZIP ( ch_fasta )

    SAMTOOLS_FAIDX ( SAMTOOLS_BGZIP.out.fasta, [[],[]], [[],[]] )

    SAMTOOLS_DICT  ( SAMTOOLS_BGZIP.out.fasta )

    emit:
    fasta_gz = SAMTOOLS_BGZIP.out.fasta        // channel: [ val(meta),  fasta.gz ]
    fai      = SAMTOOLS_FAIDX.out.fai          // channel: [ val(meta),  fai ]
    gzi      = SAMTOOLS_FAIDX.out.gzi          // channel: [ val(meta),  gzi ]
    dict     = SAMTOOLS_DICT .out.dict         // channel: [ val(meta),  dict ]

    versions = ch_versions                     // channel: [ versions.yml ]
}
