include { FASTGA_FATOGDB as FASTGA_DB_TARGET     } from '../../../modules/local/fastga/fatogdb/main'
include { FASTGA_FATOGDB as FASTGA_DB_QUERY      } from '../../../modules/local/fastga/fatogdb/main'
include { FASTGA_GIXMAKE as FASTGA_INDEX_TARGET  } from '../../../modules/local/fastga/gixmake/main'
include { FASTGA_GIXMAKE as FASTGA_INDEX_QUERY   } from '../../../modules/local/fastga/gixmake/main'
include { FASTGA_FASTGA  as FASTGA_FASTGA        } from '../../../modules/local/fastga/fastga/main'

workflow FASTGA {

    take:
    ch_target // channel: [ val(meta), genome ]
    ch_query  // channel: [ val(meta), genome ]

    main:

    ch_versions = Channel.empty()

    ch_target = ch_target.map { row -> [ [id: row[0].id + '_target' ] , row.tail() ]} // to avoid filename collisions

    FASTGA_DB_TARGET ( ch_target )
    FASTGA_DB_QUERY  ( ch_query  )
    ch_versions = ch_versions.mix(FASTGA_DB_TARGET.out.versions)

    FASTGA_INDEX_TARGET ( FASTGA_DB_TARGET.out.gdb)
    FASTGA_INDEX_QUERY  ( FASTGA_DB_QUERY .out.gdb)
    ch_versions = ch_versions.mix(FASTGA_INDEX_TARGET.out.versions)

    FASTGA_FASTGA ( FASTGA_INDEX_QUERY .out.gix.map { row -> [ [id: params.targetName + '___' + row[0].id] , row.tail() ] },
                    FASTGA_INDEX_TARGET.out.gix )
    ch_versions = ch_versions.mix(FASTGA_FASTGA.out.versions)

    emit:
    aln     = FASTGA_FASTGA.out.aln          // channel: [ val(meta), aln ]
    versions = ch_versions                   // channel: [ versions.yml ]
}
