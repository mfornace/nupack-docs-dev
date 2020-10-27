# Getting Started

## Example notebooks

Here, we provide Jupyter notebooks for a variety of examples that that can be downloaded for interactive use:

- Complex analysis: [simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-analysis/complex-analysis-simple.ipynb), [advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-analysis/complex-analysis-advanced.ipynb)
- Tube analysis: [simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-analysis/tube-analysis-simple.ipynb), [advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-analysis/tube-analysis-advanced.ipynb)
- Complex design: [simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-design/complex-design-simple.ipynb), [advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-design/complex-design-advanced.ipynb), [stickfigure](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/complex-design/complex-design-stickman.ipynb)
- Tube design: [simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-design/tube-design-simple.ipynb), [advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-design/tube-design-advanced.ipynb), [stickfigure](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/tube-design/tube-design-stickman.ipynb)
- Multitube design: [simple](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/multitube-design/multitube-design-hcr.ipynb), [advanced](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/multitube-design/multitube-design-dicer.ipynb)
- [Converting NUPACK 3 input files into NUPACK 4 scripts](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-examples/tree/master/nupack3)



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

The easiest way to install NUPACK is to install [Anaconda](https://www.anaconda.com/distribution/) by typing the following commands in a terminal:

```bash
conda update conda
conda update --all
```

You can verify your installation by running the terminal command:

```bash
conda info
```

Make sure you have Python 3.6 or newer. (If this command does not run, troubleshoot your Anaconda installation. You may not have your `$PATH` environment variable set correctly.)

After [agreeing to the NUPACK license](http://www.nupack.org/downloads/register), download the NUPACK package (e.g., `nupack-4.0.0`) into your Downloads folder and make sure it is unzipped. To install the NUPACK 4 Python module, run the following command in your terminal (type `y` when prompted):

```bash
conda install -c conda-forge -c ~/Downloads/nupack-4/package nupack jupyterlab matplotlib
```

If you change the path of your download directory, be sure to specify an absolute (not relative) path. If desired, validate your NUPACK 4 installation by running the following commands: 

```bash
conda install pytest
python -m pytest -v --pyargs nupack 
```

NUPACK 4 is now installed and you can conveniently run jobs as Jupyter notebooks. See above for [example notebooks](start.md#example-notebooks) that you can download to provide a starting point for writing your own scripts. 

To open a Jupyter notebook, launch the Anaconda-Navigator app from the Applications folder and use it to launch the Jupyter Notebook app; browse to open your notebook of choice. 

Alternatively, you can launch a web-based Jupyter notebook browser form the command line: 

```bash
conda install jupyterlab
jupyter lab
```

If no browser window appears, try navigating to the displayed link in your terminal. If this doesn't work, troubleshoot your Jupyter installation. Browse to open your notebook of choice.

For each example notebook, you can open the notebook a Jupyter lab session and click `Cell->Run All` to run the entire notebook.


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
conda install -c conda-forge -c ./nupack-latest/package nupack

jupyter lab
```

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
