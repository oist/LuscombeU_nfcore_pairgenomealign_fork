process FASTGA_GIXMAKE {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        '/home/c/charles-plessy/luscombeu_fork_of_fastga_docker.sif':
        'biocontainers/YOUR-TOOL-HERE' }"

    input:
    tuple val(meta), path(gdb)

    output:
    tuple val(meta), path("${meta.id}/"), emit: gix
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    pushd $gdb
    GIXmake \\
        $args \\
        ${gdb}.1gdb
    popd

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastga: UNRELEASED
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.gix

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastga: UNRELEASED
    END_VERSIONS
    """
}
