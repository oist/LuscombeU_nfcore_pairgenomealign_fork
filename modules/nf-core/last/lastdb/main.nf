process LAST_LASTDB {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/fc/fc775f66277d9ca6584b130ff24d9ddeaf2797f1729fadb6d73641dcaa685be7/data'
        : 'community.wave.seqera.io/library/bcftools_last_samtools_bzip2_pruned:93dbd1b10eecc490'}"

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
