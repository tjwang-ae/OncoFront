# OncoFront v1.0

OncoFront reconstructs tissue assignments and tissue contacts from spatial
transcriptomic counts. This release distributes a compiled native algorithm
module, fixed models and a small synthetic demonstration. Algorithm source code
is not included in the public installation package.

## Supported installation

The supplied binary targets **Windows x86-64 and Python 3.10 x64**. It is not a
Linux, macOS, ARM64 or Python 3.11/3.12 binary. Those platforms require their own
native build and are not represented as tested by this release.

Python 3.10 must already be installed. The automatic installer creates a separate
environment and downloads fixed dependency versions over HTTPS; internet access
to the Python package index and CPU PyTorch download service is required. An
administrator account is not required for installation in a writable user folder.

## Recommended installation

1. Download `OncoFront_Install_v1.0_Windows_x64.zip` from this repository's Release.
2. Compare its SHA256 with the published release checksum and extract the ZIP.
3. Open PowerShell in the extracted folder and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install_windows.ps1
```

If the installer cannot find Python 3.10, specify its actual path:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install_windows.ps1 -PythonPath "C:\Python310\python.exe" -InstallDir "C:\OncoFront"
```

Use a path that you can write to. Prefer a short ASCII installation path on
Windows. A custom installation path does not change the algorithm settings.
The installer refuses to overwrite an existing environment. Choose a new folder
for another installation instead of deleting input data or old result folders.

The installer checks file hashes, installs the native wheel, loads the fixed
model assets, verifies the installation and runs the demo. It creates an
`OncoFront.cmd` launcher inside the installation directory.

## Run commands

Replace `C:\OncoFront` with your actual installation directory:

```powershell
& "C:\OncoFront\OncoFront.cmd" --version
& "C:\OncoFront\OncoFront.cmd" self-test
& "C:\OncoFront\OncoFront.cmd" --help
& "C:\OncoFront\OncoFront.cmd" demo --output "C:\OncoFront\demo_second_run"
```

The example contains 144 synthetic spots. It checks software execution and file
format handling, not accuracy, prognosis or clinical utility. It does not contain
patient measurements. Successful execution writes `INFERENCE_COMPLETE.json`
and compressed spot-level and contact-edge tables.

## Analyze your data

```powershell
& "C:\OncoFront\OncoFront.cmd" prepare --cancer HNSC --counts "D:\data\counts.mtx.gz" --genes "D:\data\genes.tsv" --spots "D:\data\spots.tsv" --sample section01 --output "D:\data\prepared_section01"
& "C:\OncoFront\OncoFront.cmd" run --cancer HNSC --input "D:\data\prepared_section01" --output "D:\results\section01"
```

The example paths are illustrative. Choose the cancer-specific model matching
your data. Supported model identifiers are BRCA, CRC, HCC, HNSC, ICC, PAAD and
STAD. For input details see [INPUT_FORMAT.md](docs/INPUT_FORMAT.md).

## Outputs

- `predictions/slides/<section>/17_spot_predictions.tsv.gz`: tissue contributions,
  reference support, uncertainty and geometry information.
- `frontiers/slides/<section>/18_spot_compartments_and_frontiers.tsv.gz`: tissue
  assignments, starting spots and contact annotations.
- `frontiers/slides/<section>/18_typed_frontier_edges.tsv.gz`: reconstructed
  contact-edge types and scores.
- `INFERENCE_COMPLETE.json`: completed sections and fixed configuration.

The tissue map contains malignant epithelium, nonmalignant epithelium, stroma and
immune tissue. The separately supervised edge head predicts three epithelial–
stromal interface types. Do not confuse an edge-head class with a tissue-group
assignment or with a clinically verified invasion label.

## Important notes

- Use raw nonnegative integer counts and gene symbols, not transformed values.
- Missing genes and measured zero counts are different input states.
- Do not change model gene order, weights, preprocessing or thresholds during
  installation. Use only the model files distributed with this release.
- The set of input sections affects unsupervised expression alignment. Keep the
  same manifest when reproducing a previous analysis.
- Unassigned spots reflect insufficient assignment evidence, not confirmed
  nonmalignant tissue. A synthetic demo may contain many unassigned spots.
- Existing nonempty result directories are rejected to prevent mixed runs.
- This software is for research, not an approved clinical diagnostic product.

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for dependency, path and loading
problems. See [PROTECTION.md](docs/PROTECTION.md) for the actual binary protection
and integrity measures, including their limitations.

## License

The OncoFront core is distributed under the research-use license in `LICENSE`.
Third-party dependencies retain their own licenses. See `THIRD_PARTY_NOTICES.md`.
The paper citation should be added only when its bibliographic record is verified.
