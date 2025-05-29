# nf-core/pairgenomealign: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.2.0dev](https://github.com/nf-core/pairgenomealign/releases/tag/2.2.0)

### `Added`

- Support for export to BAM and CRAM formats ([#31](https://github.com/nf-core/pairgenomealign/issues/31)) ([#43](https://github.com/nf-core/pairgenomealign/issues/43)).
- SAM/BAM/CRAM alignments files are sorted and their header features all sequences of the _target_ genome.
- Report ungapped percent identity ([#46](https://github.com/nf-core/pairgenomealign/issues/46)).
- Update full-size test genomes to feature more T2T assemblies ([#59](https://github.com/nf-core/pairgenomealign/issues/59)).
- Use a single mulled container for LAST, Samtools and open-fonts, to save ~280 Mb of downloads ([#58](https://github.com/nf-core/pairgenomealign/issues/58)).
- Allow export to multiple formats (comma-separated list) ([#42](https://github.com/nf-core/pairgenomealign/issues/42)).

### `Dependencies`

| Dependency       | Old version | New version |
| ---------------- | ----------- | ----------- |
| `SAMTOOLS_BGZIP` |             | 1.21        |
| `SAMTOOLS_DICT`  |             | 1.21        |
| `SAMTOOLS_FAIDX` |             | 1.21        |

### `Fixed`

- Remove noisy tag in the `MULTIQC_ASSEMBLYSCAN_PLOT_DATA` local module ([#64](https://github.com/nf-core/pairgenomealign/issues/64)).
- Restore BED format support ([#56](https://github.com/nf-core/pairgenomealign/issues/56)).
- Document the `multiqc_train.txt` and `multiqc_last_o2o.txt` aggregating alignment statistics ([#52](https://github.com/nf-core/pairgenomealign/issues/52)).
- Point the test configs samplesheets to `nf-core/test-datasets` in order to run the AWS full tests ([#62](https://github.com/nf-core/pairgenomealign/issues/62)).

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
