process SAMTOOLS_FAIDX {
    tag "${fasta}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/fc/fc775f66277d9ca6584b130ff24d9ddeaf2797f1729fadb6d73641dcaa685be7/data'
        : 'community.wave.seqera.io/library/bcftools_last_samtools_bzip2_pruned:93dbd1b10eecc490'}"

    input:
    tuple val(meta), path(fasta), path(fai)
    val get_sizes

    output:
    tuple val(meta), path("*.{fa,fasta}"), emit: fa, optional: true
    tuple val(meta), path("*.sizes"), emit: sizes, optional: true
    tuple val(meta), path("*.fai"), emit: fai, optional: true
    tuple val(meta), path("*.gzi"), emit: gzi, optional: true
    tuple val("${task.process}"), val('samtools'), eval("samtools version | sed '1!d;s/.* //'"), topic: versions, emit: versions_samtools

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def get_sizes_command = get_sizes ? "cut -f 1,2 ${fasta}.fai > ${fasta}.sizes" : ''
    """
    samtools \\
        faidx \\
        ${fasta} \\
        ${args}

    ${get_sizes_command}
    """

    stub:
    def match = (task.ext.args =~ /-o(?:utput)?\s(.*)\s?/).findAll()
    def fastacmd = match[0] ? "touch ${match[0][1]}" : ''
    def get_sizes_command = get_sizes ? "touch ${fasta}.sizes" : ''
    """
    ${fastacmd}
    touch ${fasta}.fai
    if [[ "${fasta.extension}" == "gz" ]]; then
        touch ${fasta}.gzi
    fi

    ${get_sizes_command}
    """
}
