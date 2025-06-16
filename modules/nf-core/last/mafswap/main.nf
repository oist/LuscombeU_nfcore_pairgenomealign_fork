process LAST_MAFSWAP {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/06/06beccfa4d48e5daf30dd8cee4f7e06fd51594963db0d5087ab695365b79903b/data'
        : 'community.wave.seqera.io/library/last_samtools_open-fonts:176a6ab0c8171057'}"

    input:
    tuple val(meta), path(maf)

    output:
    tuple val(meta), path("*.maf.gz"), emit: maf
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    set -o pipefail
    maf-swap $args $maf | gzip --no-name > ${prefix}.swapped.maf.gz

    # maf-swap has no --version option but lastdb, part of the same package, has.
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        last: \$(lastdb --version 2>&1 | sed 's/lastdb //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo stub | gzip --no-name > ${prefix}.swapped.maf.gz

    # maf-swap has no --version option but lastdb, part of the same package, has.
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        last: \$(lastdb --version 2>&1 | sed 's/lastdb //')
    END_VERSIONS
    """
}
