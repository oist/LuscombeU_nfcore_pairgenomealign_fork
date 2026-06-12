process LAST_LASTDB {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/df/df079f31c6d6b5f7eb2d70d5df113a92f27a3d897f5593056ef19cac6ed65578/data'
        : 'community.wave.seqera.io/library/last_samtools_open-fonts:c77a5145ee22832c'}"

    input:
    tuple val(meta), path(fastx)

    output:
    tuple val(meta), path("lastdb"), emit: index
    // last-dotplot has no --version option so let's use lastal from the same suite
    tuple val("${task.process}"), val('last'), eval("lastal --version | sed 's/lastal //'"), emit: versions_last, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir lastdb
    lastdb \\
        $args \\
        -P $task.cpus \\
        lastdb/${prefix} \\
        $fastx
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir lastdb
    touch lastdb/${prefix}.bck
    touch lastdb/${prefix}.des
    touch lastdb/${prefix}.prj
    touch lastdb/${prefix}.sds
    touch lastdb/${prefix}.ssp
    touch lastdb/${prefix}.suf
    touch lastdb/${prefix}.tis

    """
}
