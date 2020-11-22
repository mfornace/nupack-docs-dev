# Getting Started

## Example Jupyter notebooks

Here, we provide Jupyter notebooks for a variety of examples that that can be downloaded for interactive use.


!!! Note

    Note that each Jupyter notebook starts by loading the NUPACK Python module: 

    ```python
    from nupack import *
    ```


### Analysis examples
Analyze the equilibrium base-pairing properties one or more test tube ensembles (or one or more complex ensembles). These are the [all-purpose sequence analysis tools](analysis.md).

- Analyze 2 strands in a test tube containing all complexes of up to 4 strands ([simple example](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-analysis/tube-analysis-simple.ipynb)). 

     

- [Advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-analysis/tube-analysis-advanced.ipynb)

### Design examples
Design the the sequences for one or more test tube ensembles (or one or more complex ensembles). These are the [all-purpose sequence design tools](design.md).

- [simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/multitube-design/multitube-design-hcr.ipynb) 
- [advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/multitube-design/multitube-design-dicer.ipynb)
- [Converting NUPACK 3 input files into NUPACK 4 scripts](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/nupack3)

- [simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-design/tube-design-simple.ipynb)
- [advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-design/tube-design-advanced.ipynb)
- [stickfigure](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-design/tube-design-stickman.ipynb)

- [simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-design/complex-design-simple.ipynb)
- [advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-design/complex-design-advanced.ipynb)
- [stickfigure](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-design/complex-design-stickman.ipynb)


### Utilities examples: 
Analyze or design a single complex ensemble. These are [quick tools](utilities.md) applicable when your ensemble is a single complex.

- [simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-analysis/complex-analysis-simple.ipynb)
- [advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-analysis/complex-analysis-advanced.ipynb)


## Installation requirements

NUPACK 4 is a C++ library distributed as a Python package. The following Python packages are required: 

- Python 3.6-3.8
- numpy
- scipy
- pandas

The following packages are recommended to facilitate interactive usage:

- matplotlib
- jupyterlab

NUPACK 4 Python packages can be installed for Mac/Linux operating systems or on the Linux subsystem of Windows 10. Alternatively, NUPACK may be compiled from source on Mac/Linux. 

## Mac/Linux installation 

The easiest way to install NUPACK is using [Anaconda](https://www.anaconda.com/distribution/).

1. Install Anaconda by running the following commands in a terminal:

    ```bash
    conda update conda
    conda update --all
    ```

2. Verify your installation (make sure you have Python 3.6 or newer):

    ```bash
    conda info
    ```

    If this command does not run, troubleshoot your Anaconda installation. You may not have your `$PATH` environment variable set correctly.

3. After [agreeing to the NUPACK license](http://www.nupack.org/downloads/register), download the NUPACK package (e.g., `nupack-4.0.0`) into your Downloads folder and make sure it is unzipped. 

4. Install the NUPACK 4 Python module by running the following command in your terminal (type `y` when prompted):

    ```bash
    conda install -c conda-forge -c ~/Downloads/nupack-VERSION/package --update-all nupack jupyterlab matplotlib
    ```

    Make sure to replace `nupack-VERSION` with the correct folder name (e.g., `nupack-4`).If you change the path of your download directory, be sure to specify an absolute (not relative) path. 

5. Validate your NUPACK 4 installation by running the following commands (type `y` when prompted): 

    ```bash
    conda install pytest
    python -m pytest -v --pyargs nupack 
    ```

6. You can now conveniently run NUPACK 4 jobs as Jupyter notebooks (see above for [example notebooks](start.md#example-notebooks)). To open a Jupyter notebook on a Mac, launch the Anaconda-Navigator app from the Applications folder and use it to launch the Jupyter Notebook app; browse to open your notebook of choice. Click `Cell->Run All` to run the entire notebook.

    Alternatively, you can launch a web-based Jupyter notebook browser from the command line: 

    ```bash
    jupyter lab
    ```

    and browse to open your notebook of choice. Click `Run->Run All Cells` to run the entire notebook. If no browser window appears, try navigating to the displayed link in your terminal. If this doesn't work, troubleshoot your Jupyter installation. 


---


## Windows installation

NUPACK may be installed on Windows 10 using the Windows Subsystem for Linux 2 (WSL2).

1. Click the start menu and search for "Windows Features". Click on "Turn Windows features on or off". Check the "Windows Subsystem for Linux" icon

> <img src="/figs/windows/winfeatures.PNG" alt="Windows features" title="Windows features" width="400" />

2. Download Ubuntu from the Microsoft Store

> <img src="/figs/windows/ubuntudl.PNG" alt="Windows store" title="Windows store" width="400" />

3. Open the Ubuntu app and set a username and password
> <img src="/figs/windows/ubuntusetup2.PNG" alt="Ubuntu setup" title="Ubuntu setup" width="400" />

4. (Optional) Open the properties window and enable copy paste

> <img src="/figs/windows/properties.PNG" alt="Ubuntu properties" title="Ubuntu properties" width="400" />

5. Install NUPACK as if using Linux using the following commands (type `y` when prompted):

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
conda install -c conda-forge -c ./nupack-VERSION/package --update-all nupack

jupyter lab
```

Make sure to replace `nupack-VERSION` with the correct folder name (e.g., `nupack-4`).

6. Use your web browser to open localhost:8888 and use Jupyter Lab to open an [example notebook](start.md#example-notebooks). 


---

## Source installation

For Mac/Linux users, installation via Anaconda is by far the easiest option and is strongly recommended. However, if necessary, NUPACK can be built from source.

The following are required: 

- C++17 compliant compiler (Clang or AppleClang)
- CMake

Directions:

1. On a Mac/Linux system, navigate to the `source` directory within the NUPACK download:

```bash
cd ~/Downloads/nupack-4/source 
```

2. Build the included `vcpkg` submodule using:

```bash
./external/vcpkg/bootstrap-vcpkg.sh
```

or if you are using a Mac and have not previously installed a C++ compiler, using the following flags:

```bash
./external/vcpkg/bootstrap-vcpkg.sh --useSystemBinaries --allowAppleClang
```

3. Next install the dependencies for NUPACK compilation using `vcpkg`:

```
./external/vcpkg/vcpkg install armadillo tbb gecode \
    nlohmann-json jsoncpp tclap spdlog boost-context boost-graph boost-align boost-ublas \
    boost-variant boost-thread boost-sort boost-geometry boost-odeint boost-coroutine2
```

4. Make a build directory and navigate into it:

```bash
mkdir build
cd build
```

5. Run the CMake configuration:

```bash
cmake .. -DCMAKE_BUILD_TYPE=Release
```

You may add custom compilation options as flags to the `cmake` command if desired. Some examples might be:

- Add `-DCMAKE_CXX_COMPILER=clang++` to use the `clang++` compiler. As noted above, compilers besides `clang` are not generally supported.
- Add `-DREBIND_PYTHON=/usr/local/bin/python3` to build for a specific Python executable (by default, the `python` in the user's `$PATH` is used).
- Add `-DCMAKE_CXX_FLAGS="<custom compile options>"` to add custom C++ compilation flags.

6. Build the C++ code:

```bash
cmake --build . --target nupack-python
```

7. Install the NUPACK Python module:

```bash
pip3 install .
```
