process FASTGA_FATOGDB {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        '/home/c/charles-plessy/luscombeu_fork_of_fastga_docker.sif':
        'biocontainers/YOUR-TOOL-HERE' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("${meta.id}/"), emit: gdb
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir ${prefix}
    FAtoGDB \\
        $args \\
        $fasta \\
        ${meta.id}/${prefix}.1gdb

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastga: UNRELEASED
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastga: UNRELEASED
    END_VERSIONS
    """
}
