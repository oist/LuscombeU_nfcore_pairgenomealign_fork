include { SAMTOOLS_BGZIP     } from '../../../modules/nf-core/samtools/bgzip/main'
include { SAMTOOLS_DICT      } from '../../../modules/nf-core/samtools/dict/main'
include { SAMTOOLS_FAIDX     } from '../../../modules/nf-core/samtools/faidx/main'

workflow FASTA_BGZIP_INDEX_DICT_SAMTOOLS {

    take:
    ch_fasta // channel: [ val(meta), fasta ]

    main:

    // Guarantee BGZIP compression
    SAMTOOLS_BGZIP ( ch_fasta )

    SAMTOOLS_FAIDX ( SAMTOOLS_BGZIP.out.fasta, [[],[]], [[],[]] )

    SAMTOOLS_DICT  ( SAMTOOLS_BGZIP.out.fasta )

    ch_joined = SAMTOOLS_BGZIP.out.fasta
        .join(SAMTOOLS_FAIDX.out.fai)
        .join(SAMTOOLS_FAIDX.out.gzi)
        .join(SAMTOOLS_DICT.out.dict)
        .map { meta, fasta, fai, gzi, dict ->
            [ meta, fasta, fai, gzi, dict ]
        }

    emit:
    fasta_fai_gzi_dict = ch_joined             // channel: [ val(meta),  fasta.gz, fai, gzi, dict ]
}
