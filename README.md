About
=====

MTEX is an open source MATLAB toolbox for crystallographic texture
analysis. Its main features are

* crystal geometry, symmetries, Miller indices
* orientation maps, e.g. from EBSD, transmission EBSD
* diffraction pole figures, e.g. from XRD, synchrotron, neutron
* ODF reconstruction from pole figures or individual orientations
* grain reconstruction from orientation maps
* grain boundary analysis
* orientation distribution analysis
* elastic and plastic deformations
* texture simulation and texture evolution
* publication ready plots
* batch processing of many data sets

In contrast to many other software

* it has no graphical user interface
* it is not restricted to any particular EBSD or XRD device
* is completely customizable
* does support all crystallographic point groups (not only Laue groups)

More detail can be found in the [documentation](http://mtex-toolbox.github.io/documentation.html).


Installation and requirements
=============================

MTEX requires Matlab (R2014b) or later and come with binaries from the
[NFFT](https://www-user.tu-chemnitz.de/~potts/nfft/).

To install proceed as follows:

1. download and extract the zip file to an arbitrary folder
2. start Matlab (version 2014b or newer required
3. change the current folder in Matlab to the folder where MTEX is installed
4. type `startup_mtex` into the command window
5. click one of the menu items to import data or to consult the documentation

Contributing
============

Since MTEX is open source we are happy about any kind of contribution. In
order suggest bug fixes, new features or improved documentation to MTEX
proceed as follows:

1. fork the MTEX repository to your personal GitHub account
2. clone it on your local computer
3. apply your changes
4. push your changes to your personal GitHub account
5. create a pull request to MTEX/development

Note, that when cloning MTEX the binaries in `mtex/mex` and `mtex/extern/nfft`
are not included but must be copied from an zip-file based installation as
explained above.

License
=======

See `COPYING.txt` for MTEX's licensing information.
