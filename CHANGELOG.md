# nf-core/pairgenomealign: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.3.0](https://github.com/nf-core/pairgenomealign/releases/tag/2.3.0) "Umi budou" - [June 3rd 2026]

### `Added`

- New `--multi_cram` option to produce a multi-query CRAM file combining all the alignments ([#60](https://github.com/nf-core/pairgenomealign/issues/60)).
- New `--multiqc_thumbs` option to produce alignment thumbnails in the MultiQC report ([#93](https://github.com/nf-core/pairgenomealign/issues/93)).
- New `--strand` option to index only one strand of the genome, which reduces memory usage at the expense of speed, and suppresses `-/+` alignments ([#97](https://github.com/nf-core/pairgenomealign/issues/97)).
- New `--query` and `--queryName` convenience options to skip samplesheet creation when there is only one _query_ genome to align ([#112](https://github.com/nf-core/pairgenomealign/issues/112)).
- In the GFF export format, the _target_ genome sequence lengths are now exported in `##sequence-region` fields ([#70](https://github.com/nf-core/pairgenomealign/issues/70)).

### `Fixed`

- Using the nf-core version of the `FASTA_BGZIP_INDEX_DICT_SAMTOOLS` subworkflow that we just contributed.
- Check for input file existence in the parameter schema [#73](https://github.com/nf-core/pairgenomealign/issues/73)).

### `Parameters`

| Old parameter | New parameter      |
| ------------- | ------------------ |
|               | `--multi_cram`     |
|               | `--multiqc_thumbs` |
|               | `--query`          |
|               | `--queryName`      |
|               | `--strand`         |

### `Dependencies`

| Dependency          | Old version | New version |
| ------------------- | ----------- | ----------- |
| `SAMTOOLS_BGZIP`    | 1.21        |             |
| `SAMTOOLS_DICT`     | 1.21        | 1.23.1      |
| `SAMTOOLS_FAIDX`    | 1.21        | 1.23.1      |
| `SAMTOOLS_MERGE`    |             | 1.23.1      |
| `HTSLIB_BGZIPTABIX` |             | 1.23.1      |

## [v2.2.3](https://github.com/nf-core/pairgenomealign/releases/tag/2.2.3) "Reitou mikan" - [May 20th 2026]

### `Fixed`

- Conforms to [nf-core template version `4.0.2`](https://nf-co.re/blog/2026/tools-4_0_0) ([#107](https://github.com/nf-core/pairgenomealign/issues/107)).
- Improve description of what the pipeline does and how ([#108](https://github.com/nf-core/pairgenomealign/issues/108)).

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `MultiQC`  | 1.33        | 1.34        |

## [v2.2.2](https://github.com/nf-core/pairgenomealign/releases/tag/2.2.2) "Juicy" - [January 30th 2026]

### `Fixed`

- Conforms to [nf-core template version `3.5.1`](https://nf-co.re/blog/2025/tools-3_5_0) ([#95](https://github.com/nf-core/pairgenomealign/issues/95), [#98](https://github.com/nf-core/pairgenomealign/issues/98)).
- Fixed nf-core logo ([#90](https://github.com/nf-core/pairgenomealign/issues/90)).
- Adjusted process requirements to `test_full` case ([#61](https://github.com/nf-core/pairgenomealign/issues/61)).
- Set an icon in the `--targetName` option in the documentation ([#92](https://github.com/nf-core/pairgenomealign/issues/92)).
- Fixed a bug of `last/train` records the wrong value for percent identity ([#96](https://github.com/nf-core/pairgenomealign/issues/96)).
- Merged output channels in `last/dotplot` ([#100](https://github.com/nf-core/pairgenomealign/issues/100))
- Created missing `meta.yml` for subworkflows ([#101](https://github.com/nf-core/pairgenomealign/issues/101)).
- Exclude PNG files from pipeline test, because not reproducible in conda.
- Display the _target_ genome length in the MultiQC report ([#77](https://github.com/nf-core/pairgenomealign/issues/77)).

### `Dependencies`

| Dependency     | Old version | New version |
| -------------- | ----------- | ----------- |
| `assemblyscan` | 0.4.1       | 1.0.0       |
| `MultiQC`      | 1.30        | 1.33        |

## [v2.2.1](https://github.com/nf-core/pairgenomealign/releases/tag/2.2.1) "C’est quoi ça?" - [August 5th 2025]

### `Fixed`

- Conforms to nf-core template version 3.3.2, hopefully fixing AWS tests ([#85](https://github.com/nf-core/pairgenomealign/pull/85)) ([#83](https://github.com/nf-core/pairgenomealign/pull/83)).
- Added missing pipeline and subworkflow test snapshots and stabilise line order in some output files ([#84](https://github.com/nf-core/pairgenomealign/pull/84)).
- Update modules to latest version, thereby pulling an important fix for a race condition in `last/mafconvert` ([#87](https://github.com/nf-core/pairgenomealign/pull/87)), ([#88](https://github.com/nf-core/pairgenomealign/pull/88)).
- Report `jq` version used in `MULTIQC_ASSEMBLYSCAN_PLOT_DATA` ([#81](https://github.com/nf-core/pairgenomealign/pull/81)).
- Document module names in tube map ([#74](https://github.com/nf-core/pairgenomealign/pull/74)).
- Add mising modules in tube map ([#68](https://github.com/nf-core/pairgenomealign/pull/68)).
- Materialise output files in tube map ([#75](https://github.com/nf-core/pairgenomealign/pull/75)).

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `MultiQC`  | 1.28        | 1.30        |

## [v2.2.0](https://github.com/nf-core/pairgenomealign/releases/tag/2.2.0) "Chagara ponzu" - [May 29th 2025]

### `Added`

- Support for export to BAM and CRAM formats ([#31](https://github.com/nf-core/pairgenomealign/issues/31)) ([#43](https://github.com/nf-core/pairgenomealign/issues/43)).
- SAM/BAM/CRAM alignments files are sorted and their header features all sequences of the _target_ genome.
- Report ungapped percent identity ([#46](https://github.com/nf-core/pairgenomealign/issues/46)).
- Update full-size test genomes to feature more T2T assemblies ([#59](https://github.com/nf-core/pairgenomealign/issues/59)).
- Use a single mulled container for LAST, Samtools and open-fonts, to save ~280 Mb of downloads ([#58](https://github.com/nf-core/pairgenomealign/issues/58)).
- Allow export to multiple formats (comma-separated list) ([#42](https://github.com/nf-core/pairgenomealign/issues/42)).
- Allow skipping of the assembly QC with `--skip_assembly_qc` ([#53](https://github.com/nf-core/pairgenomealign/issues/53)).

### `Dependencies`

| Dependency       | Old version | New version |
| ---------------- | ----------- | ----------- |
| `SAMTOOLS_BGZIP` |             | 1.21        |
| `SAMTOOLS_DICT`  |             | 1.21        |
| `SAMTOOLS_FAIDX` |             | 1.21        |

### `Parameters`

| Old parameter | New parameter        |
| ------------- | -------------------- |
|               | `--skip_assembly_qc` |

### `Fixed`

- Remove noisy tag in the `MULTIQC_ASSEMBLYSCAN_PLOT_DATA` local module ([#64](https://github.com/nf-core/pairgenomealign/issues/64)).
- Restore BED format support ([#56](https://github.com/nf-core/pairgenomealign/issues/56)).
- Document the `multiqc_train.txt` and `multiqc_last_o2o.txt` aggregating alignment statistics ([#52](https://github.com/nf-core/pairgenomealign/issues/52)).
- Point the test configs samplesheets to `nf-core/test-datasets` in order to run the AWS full tests ([#62](https://github.com/nf-core/pairgenomealign/issues/62)).
- Update metro map, in white background ([#71](https://github.com/nf-core/pairgenomealign/issues/71)).
- Removed the `last/mafswap` module, which was actually not used.

## [v2.1.0](https://github.com/nf-core/pairgenomealign/releases/tag/2.1.0) "Goya champuru" - [May 16th 2025]

### `Added`

- New `--dotplot_filter` paramater to produce extra alignment plots where small off-diagonal signal is filtered out ([#35](https://github.com/nf-core/pairgenomealign/issues/35)).
- New `--dotplot_width`, `--dotplot_height` and `--dotplot_font_size` parameters to control alignment plot size ([#38](https://github.com/nf-core/pairgenomealign/issues/38)).

### `Fixed`

- In alignment plots, contig names are now written with a nice scalable font instead of being pixellised ([#44](https://github.com/nf-core/pairgenomealign/issues/44)).
- Conforms to nf-core template version 3.2.1 ([#54](https://github.com/nf-core/pairgenomealign/pull/54)).
- Removed some old linting exceptions.
- Removed the `gfastats` modules, which was actually not used.
- Make sure the subworkflows collect all module versions.
- Fix plot IDs for comptatibility with MultiQC 1.28.

### `Parameters`

| Old parameter | New parameter         |
| ------------- | --------------------- |
|               | `--dotplot_filter`    |
|               | `--dotplot_font_size` |
|               | `--dotplot_height`    |
|               | `--dotplot_width`     |

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `LAST`     | 1608        | 1611        |
| `MultiQC`  | 1.27        | 1.28        |

## [v2.0.0](https://github.com/nf-core/pairgenomealign/releases/tag/2.0.0) "Naga imo" - [February 5th, 2025]

### `Breaking changes`

- The LAST software was updated and it has new defaults for some of its
  parameters. The alignments ran with this pipeline will not be identical to
  the ones from older versions.

### `Added`

- The `alignment/lastdb` directory is not output anymore. It consumed space,
  is not usually needed for downstream analysis, and can be re-computed
  identically if needed.
- The _many-to-one_ alignment file is not output anymore by default, to save
  space. To keep this file, you can run the pipeline in `many-to-many` mode
  with the `--m2m` parameter.
- The `--seed` parameter allows for all the existing values in the `lastdb`
  program.
- Errors caused by absence of alignments at training or plotting steps
  are now ignored.
- New parameter `--export_aln_to` that creates additional files containing
  the alignments in a different format such as Axt, Chain, GFF or SAM.

### `Fixed`

- Incorrect detection of regions with 10 or more `N`s was corrected ([#18](https://github.com/nf-core/pairgenomealign/issues/18)).
- The `--lastal_params` now works as intended instead of being ignored ([#22](https://github.com/nf-core/pairgenomealign/issues/22)).
- The _workflow summary_ is now properly sorted at the end of the MultiQC report ([#32](https://github.com/nf-core/pairgenomealign/issues/32)).
- Conforms to nf-core template version 3.2.0 ([#40](https://github.com/nf-core/pairgenomealign/pull/40)).

### `Parameters`

| Old parameter | New parameter     |
| ------------- | ----------------- |
|               | `--export_aln_to` |

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `LAST`     | 1542        | 1608        |
| `MultiQC`  | 1.25.1      | 1.27        |

## [v1.1.1](https://github.com/nf-core/pairgenomealign/releases/tag/1.1.1) "Kani nabe" - [December 17th, 2024]

### `Broken`

- In retrospect it was found that this version (only) is not compatible with
  Nextflow 25.04 or higher. Please use `v1.1.0` instead if you need the same
  functionality and software version numbers.

### `Fixed`

- This release brings the pipeline to the standards of Nextflow 24.10.1 and
  nf-core 3.1.0.

## [v1.1.0](https://github.com/nf-core/pairgenomealign/releases/tag/1.1.0) "Nattou maki" - [September 27th, 2024]

### `Added`

- Added a new `softmask` parameter, to optionally keep original softmasking.

### `Parameters`

| Old parameter | New parameter |
| ------------- | ------------- |
|               | `--softmask`  |

## [v1.0.0](https://github.com/nf-core/pairgenomealign/releases/tag/1.0.0) "Sweet potato" - [August 27th, 2024]

Initial release of nf-core/pairgenomealign, created with the [nf-core](https://nf-co.re/) template.
