# Getting Started

## Installation



### Requirements

NUPACK 4 is a C++ library distributed as a Python package for portability and ease of use. Before installing NUPACK, you must have Python 3 and a few common packages installed on your computer. Note that Python 2 is not currently supported. The specific Python package requirements for NUPACK 4 are:

- Python 3.6+
- numpy
- scipy

For full visualization capabilities, the following packages are recommended:

- matplotlib
- bokeh
- notebook

### Installing NUPACK via the Anaconda Python package

The easiest way to install NUPACK is to install [Anaconda](https://www.anaconda.com/distribution/), which comes with many Python packages preinstalled. Alternatively, you can install [Miniconda](https://docs.conda.io/en/latest/miniconda.html) for a smaller installation size. Make sure the distribution you use contains Python 3.6 or newer.

Next, open a new window in your terminal. It is often helpful to update your installation of Anaconda by running the following terminal commands:

```bash
conda update conda
conda update --all
```

You can verify your installation by running the terminal command:

```bash
conda info
```

The output of this command should show your Python version and other information. (If this command cannot be run, troubleshoot your Anaconda installation. You may not have your `$PATH` environmental variable set correctly.)

 The following instructions will assume you are installing NUPACK 4.0.0; replace any instances of `4.0.0` with your downloaded version number if it differs. After installing your preferred distribution, download the NUPACK package `nupack-4.0.0` into your Downloads folder. If you have a `tar.gz` file, decompress it. Then open Terminal and run the following command:

```bash
conda install -c conda-forge -c ~/Downloads/nupack-4.0.0 nupack
```

This step should usually complete in 1 minute or less; it should always take less than 5 minutes. You can change the path of your downloaded directory as you want, but be aware that you must use a full (not relative) path. This command will install the NUPACK C++ and Python packages. To validate your installation, run the following:

```bash
conda install pytest
pytest -v --pyargs nupack
```

Example notebooks are provided within the distributed package. In Terminal, navigate to the `nupack-4.0.0` directory (for example, `cd ~/Downloads/nupack-4.0.0`).
For each example notebook `Analysis.ipynb`, `Design.ipynb`, and `ConversionFromNUPACK3.ipynb`, open the notebook and click `Cell->Run All` to run the entire notebook.
See the next section for help on opening the Jupyter notebooks.

#### Opening a Jupyter notebook from the Anaconda GUI

Open the Anaconda application and select the JupyterLab option to open a notebook browser. Browse to open the desired notebook using the left toolbar.

#### Opening a Jupyter notebook from the command line

Run the following commands in your terminal from your desired directory:

```bash
conda install jupyterlab
jupyter lab
```

If no browser window appears, you may try navigating to the displayed link in your terminal (this URL should look like <http://127.0.0.1:8889/?token=78f1ffcdcf04cec0e97e74912e36b4eb5b530aa546411ea3>). If this doesn't work, troubleshoot your Jupyter installation. Browse to open the desired notebook using the GUI in your web browser.

### Installing NUPACK from source

#### External dependencies for C++ libraries

- C++17 compliant compiler (works with Clang 3.6+, AppleClang, maybe GCC 5+)
- [Boost](https://www.boost.org) (1.58+, optionally including Boost Context)

All are available on [Homebrew](https://brew.sh) for Mac. For example, after Homebrew is installed, run `brew install tbb armadillo boost`. They are also commonly available in Linux package managers (e.g. `apt-get`, `pacman`).

#### Directions

Make sure `python` points to your desired version of Python. On a Unix-like system, clone the repository and install in Terminal via the following commands.

Clone the git repository for NUPACK.
```bash
git clone --recurse-submodules git@github.com:mfornace/nupack.git
```
Make a build folder and navigate into it.
```bash
cd nupack
mkdir build
cd build
```
Run the CMake configuration. You may add any custom compilation options as flags to the `cmake` command if desired. For instance, you could add `-DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_CXX_COMPILER=clang++` to use a specified install directory and C++ compiler.
```
cmake ..
```
Build the NUPACK Python module.
```bash
cmake --build . --target python
```
Install the NUPACK Python module and binding module.

```bash
pip3 install ../external/rebind
pip3 install .
```

### Bundled packages

Each of the following packages is included as a git subrepository.

#### Included C++ packages

- [Armadillo](https://arma.sourceforge.net/) (a local installation of version 9.500 or later can also be used)
- [JSON for Modern C++](https://github.com/nlohmann/json>)
- [Boost.SIMD](https://github.com/nickporubsky/boost-simd-clone>)

#### Included CMake packages

- [cotire.cmake](https://github.com/sakra/cotire>)
- [CMake common modules](https://github.com/Eyescale/CMake>)
- [CMake modules (for git revision)](https://github.com/rpavlik/cmake-modules>)




## Examples

### Analysis examples
### Design examples
### Utilities examples
### Converting from NUPACK 3 examples

See the following usage examples derived from Jupyter notebooks that are bundled with NUPACK 4. You may also view these notebooks on [nbviewer](https://nbviewer.jupyter.org/github/mfornace/nupack-nbviewer/tree/master/) or [GitHub](https://github.com/mfornace/nupack-nbviewer/).

1. [Analysis](https://github.com/mfornace/nupack-documentation/blob/docs/notebooks/Analysis.ipynb)
2. [Design](https://github.com/mfornace/nupack-documentation/blob/docs/notebooks/Design.ipynb)
3. [Conversion from NUPACK 3](https://github.com/mfornace/nupack-documentation/blob/docs/notebooks/ConversionFromNUPACK3.ipynb)

!!!todo
    Currently the above links are to github, but we can switch to nbviewer once they're public. You may need to sign into GitHub to see the above links.

