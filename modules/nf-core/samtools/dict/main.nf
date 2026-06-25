process SAMTOOLS_DICT {
    tag "${fasta}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/fc/fc775f66277d9ca6584b130ff24d9ddeaf2797f1729fadb6d73641dcaa685be7/data'
        : 'community.wave.seqera.io/library/bcftools_last_samtools_bzip2_pruned:93dbd1b10eecc490'}"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.dict"), emit: dict
    tuple val("${task.process}"), val('samtools'), eval("samtools version | sed '1!d;s/.* //'"), topic: versions, emit: versions_samtools

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    samtools \\
        dict \\
        ${args} \\
        ${fasta} \\
        > ${fasta}.dict

    """

    stub:
    """
    touch ${fasta}.dict
    """
}
