# OncoFront v1.0

OncoFront estimates tissue RNA fractions and reconstructs tissue contacts from spatial transcriptomic counts. This release provides a compiled CPU module, fixed models for seven cancers and a synthetic head and neck cancer example.

## Install on Linux

From a repository checkout, run `bash install.sh` to download and verify the Linux installer. Alternatively, install from the release archive using the commands below.

Download `OncoFront_Linux.zip` from [the v1.0 release](https://github.com/tjwang-ae/OncoFront/releases/tag/V1.0). Extract it in a writable directory. The target is Linux x86-64 with CPython 3.10, glibc 2.35, Bash, OpenSSL, unzip and Python venv support. The initial installation downloads scientific Python dependencies and CPU PyTorch. Select a new destination directory.

```bash
unzip OncoFront_Linux.zip -d OncoFront_Linux
cd OncoFront_Linux
PYTHON=python3.10 bash install.sh
export PATH="$HOME/.local/OncoFront:$PATH"
oncofront --version
oncofront verify-assets
```

To use the command in new shells, add the export line above to your shell profile. The installer runs the included demo and saves its results under the installation directory in `demo_output/`. For offline installation, set `ONCOFRONT_WHEELHOUSE` to a directory containing the compatible Linux wheels for all runtime dependencies, including CPU PyTorch. Model and demo data are included in the installer.

## Run the synthetic example

The demo contains 144 synthetic spots and 200 genes. The count matrix and spot coordinates are provided under `demo/`. These data test installation and inference.

```bash
oncofront demo --output demo_results

# Prepare a new input bundle from the supplied counts, then analyze it.
oncofront prepare --cancer HNSC --counts demo/counts.mtx.gz --genes demo/genes.tsv \
  --spots demo/spots.tsv --sample SyntheticSection01 --output prepared
oncofront run --cancer HNSC --input prepared --output results
```

Use a new or empty output directory for each run. The CLI supports BRCA, CRC, HCC, HNSC, ICC, PAAD and STAD. Specify the model for the tissue of origin. Counts are raw nonnegative integers with spots in rows and gene symbols in columns. Use `--transpose` for genes in rows. The order of identifiers in each table must match the corresponding matrix dimension. Supply `SpotID`, `SpatialX` and `SpatialY` in the coordinate table. Missing genes and measured genes with zero counts carry distinct information. Keep the section manifest fixed when comparing runs because the program estimates expression alignment across the supplied sections.

## Read the results

| File beneath the output directory | Contents |
| --- | --- |
| `predictions/slides/<section>/spot_predictions.tsv.gz` | Tissue RNA contributions, uncertainty and geometry |
| `predictions/slides/<section>/graph_edges.tsv.gz` | Spatial adjacency and supervised interface scores |
| `frontiers/slides/<section>/spot_compartments_and_frontiers.tsv.gz` | Region labels, starting spots and contacts |
| `frontiers/slides/<section>/typed_frontier_edges.tsv.gz` | Contact-edge types and scores |
| `INFERENCE_COMPLETE.json` | Completion and configuration for the run |

Unassigned spots have insufficient support for a tissue label. Six types of adjacency can occur among four tissue groups. The supervised edge head separately scores three tissue pairs. Use the software for research under the terms in `LICENSE`.
