process SAMTOOLS_DICT {
    tag "${fasta}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/df/df079f31c6d6b5f7eb2d70d5df113a92f27a3d897f5593056ef19cac6ed65578/data'
        : 'community.wave.seqera.io/library/last_samtools_open-fonts:c77a5145ee22832c'}"

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
