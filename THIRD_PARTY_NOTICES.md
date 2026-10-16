# Third-party components

The OncoFront native core uses separately installed numerical and support
libraries, including NumPy, SciPy, pandas, scikit-learn, PyTorch, NetworkX,
PyYAML and cryptography. Their original copyright and license notices remain
in their installed distributions. The OncoFront research-use license does not
override their licenses or remove their source-access rights where applicable.

The native build uses Nuitka and a GCC-based toolchain. Compiler source, build
scripts and intermediate output are not part of the public OncoFront installer.
The compiler's applicable output and runtime exceptions must be retained and
reviewed for the actual distributed native artifact.

All dependencies must be obtained from their official or authorized package
distributions. Redistributing a separate offline dependency bundle requires
retaining each included distribution's original notices and licenses.
