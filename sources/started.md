# Getting started

## Installation
### Requirements

NUPACK 4 is a C++ library distributed as a Python package for portability and ease of use. Before installing NUPACK, you must have Python 3 and a few common packages installed on your computer. Note that Python 2 is not currently supported. The specific Python package requirements for NUPACK 4 are:

- Python 3.6-3.8
- numpy
- scipy
- pandas

For interactive usage, the following packages are recommended:

- matplotlib
- jupyterlab

NUPACK 4 Python packages are provided for Mac and Linux operating systems. Windows is *not*  directly supported, though we hope to address this in the future. Windows 10 users may instead to install NUPACK on the [Linux subsystem](#installing-nupack-on-windows).

### Mac/Linux as Anaconda Python package

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

While not strict prerequisites for installation, we advise that you install

After installing your preferred distribution, download the NUPACK package `nupack-4.0.0` into your Downloads folder. If you have a `.zip` file, decompress it. Then open Terminal and run the following command (type __y__ when prompted):

```bash
conda install -c conda-forge -c ~/Downloads/nupack-4/package nupack jupyterlab matplotlib
```

<!-- This step should usually complete in 1 minute or less; it should always take less than 5 minutes.  -->
You can change the path of your downloaded directory as you need, but be aware that you must use a full (not relative) path. This command will install the NUPACK C++ and Python packages. To validate your installation, you may run the following:

```bash
conda install pytest
pytest -v --pyargs nupack # optional, may take a couple of minutes
```

Example notebooks are provided within the distributed package. In Terminal, navigate to the `nupack-4` directory (for example, `cd ~/Downloads/nupack-4/examples`).
For each example notebook therein, you can open the notebook a Jupyter lab session and click `Cell->Run All` to run the entire notebook.
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

---


### Windows

NUPACK may be installed on Windows 10 using the Windows Subsystem for Linux 2 (WSL2).

1. Click the start menu and search for "Windows Features", click on "Turn Windows Features On or Off". Check the "Windows Subsystems for Linux icon"

> <img src="/figs/windows/winfeatures.PNG" alt="Windows features" title="Windows features" width="400" />

2. Download Ubuntu from the Microsoft Store

> <img src="/figs/windows/ubuntudl.PNG" alt="Windows store" title="Windows store" width="400" />

3. Open the Ubuntu app and set a username and password
> <img src="/figs/windows/ubuntusetup2.PNG" alt="Ubuntu setup" title="Ubuntu setup" width="400" />

4. (Optional) Open the properties window and enable copy paste

> <img src="/figs/windows/properties.PNG" alt="Ubuntu properties" title="Ubuntu properties" width="400" />

5. Install NUPACK normally as if using Linux. Specifically run these commands in order and type __y__ when prompted:

```bash
mkdir nupack-latest
cd nupack-latest
cp /mnt/c/Users/YourUserName/Downloads/nupack-latest.zip ./
sudo apt install unzip
unzip nupack-latest.zip
cd ..

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
/bin/bash Miniconda3-latest-Linux-x86_64.sh -b
miniconda3/bin/conda update -n base -c defaults conda
rm Miniconda3-latest-Linux-x86_64.sh

export PATH=$HOME/miniconda3/bin:$PATH
echo 'export PATH=$HOME/miniconda3/bin:$PATH' >> ~/.bashrc

conda install -c conda-forge numpy scipy pip matplotlib pandas jupyterlab
conda install -c conda-forge -c ./nupack-latest/package nupack

jupyter lab
```

6. Open localhost:8888 with your browser and use Jupyter lab with NUPACK installed


---

### Source

Installation via Anaconda is by far the easiest option and is recommended for almost every user. However, NUPACK may also be built from source if it is desired.

### External dependencies for C++ libraries

- C++17 compliant compiler (generally requires Clang or AppleClang)
- CMake

### Directions

1. On a Unix-like system, navigate to the `source` folder in the provided download:

```bash
cd ~/Downloads/nupack-4/source # navigate to the source directory
```

2. Next build the included `vcpkg` submodule:

```bash
./external/vcpkg/bootstrap-vcpkg.sh
```

If you are using a Mac and have not previously installed a C++ compiler, use the following flags:

```bash
./external/vcpkg/bootstrap-vcpkg.sh --useSystemBinaries --allowAppleClang
```

3. Next install the dependencies for NUPACK compilation using `vcpkg`:

```
./external/vcpkg/vcpkg install armadillo tbb gecode \
    nlohmann-json jsoncpp tclap spdlog boost-context boost-graph boost-align boost-ublas \
    boost-variant boost-thread boost-sort boost-geometry boost-odeint boost-coroutine2
```

4. Make a build folder and navigate into it.

```bash
mkdir build
cd build
```

5. Run the CMake configuration.

```bash
cmake .. -DCMAKE_BUILD_TYPE=Release
```

You may add custom compilation options as flags to the `cmake` command if desired. Some examples might be:

- Add `-DCMAKE_CXX_COMPILER=clang++` to use the `clang++` compiler. As noted above, compilers besides `clang` are not generally supported.
- Add `-DREBIND_PYTHON=/usr/local/bin/python3` to build for a specific Python executable (by default, the `python` in the user's `$PATH` is used).
- Add `-DCMAKE_CXX_FLAGS="<custom compile options>"` to add custom C++ compilation flags.

6. Build the C++ code.

```bash
cmake --build . --target nupack-python
```

7. Install the NUPACK Python module.

```bash
pip3 install .
```

## Examples

A number of Jupyter notebooks are bundled with the NUPACK 4 download in the `examples/` folder. For reference, non-interactive versions of these notebooks may be found on [nbviewer](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/).

Examples are provided for the following use cases:

- Complex analysis ([simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-analysis/complex-analysis-simple.ipynb)/[advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-analysis/complex-analysis-advanced.ipynb))
- Tube analysis ([simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-analysis/tube-analysis-simple.ipynb)/[advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-analysis/tube-analysis-advanced.ipynb))
- Complex design ([simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-design/complex-design-simple.ipynb)/[advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-design/complex-design-advanced.ipynb)/[stickman](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-design/complex-design-stickman.ipynb))
- Tube design ([simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-design/tube-design-simple.ipynb)/[advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-design/tube-design-advanced.ipynb)/[stickman](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-design/tube-design-stickman.ipynb))
- Multitube design ([simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/multitube-design/multitube-design-hcr.ipynb)/[advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/multitube-design/multitube-design-dicer.ipynb))
- [Small examples of converting NUPACK 3 input files to NUPACK 4 scripts](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/nupack3)

---
