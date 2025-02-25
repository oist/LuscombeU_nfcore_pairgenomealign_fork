process FASTGA_FASTGA {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        '/home/c/charles-plessy/luscombeu_fork_of_fastga_docker.sif':
        'biocontainers/YOUR-TOOL-HERE' }"

    input:
    tuple val(meta),  path(query)
    tuple val(meta2), path(target)

    output:
    tuple val(meta), path("*.1aln"), emit: aln
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    FastGA \\
        $args \\
        -1:${prefix}.1aln \\
        ${target}/*.gix \\
        ${query}/*.gix

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
