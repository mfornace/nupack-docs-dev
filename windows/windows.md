# Installing NUPACK on Windows using WSL 2
1. Download Ubuntu from the Microsoft Store
	![Store](/windows/figs/ubuntudl.PNG)
2. Open the Ubuntu app and set a username and password
![Setup](/windows/figs/ubuntusetup2.PNG)
	* (Optional) Open the properties window and enable copy paste
	![Setup](/windows/figs/properties.PNG)
3. Install NUPACK normally as if using Linux. Specifically run these commands in order and type __y__ when prompted:

``` 
mkdir nupack-latest
cd nupack-latest
wget -O nupack-latest.zip "oururlhere"
sudo apt install unzip
unzip nupack-latest.zip
cd ..

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
/bin/bash Miniconda3-latest-Linux-x86_64.sh -b
miniconda3/bin/conda update -n base -c defaults conda
rm Miniconda3-latest-Linux-x86_64.sh

export PATH=$HOME/miniconda3/bin:$PATH
echo 'export PATH=$HOME/miniconda3/bin:$PATH' >> ~/.bashrc

conda install -c conda-forge numpy scipy pip matplotlib bokeh pandas jupyterlab
conda install -c conda-forge -c ./nupack-latest/package nupack

jupyter lab
```

4. Open localhost:8888 with your browser and use Jupyter lab with NUPACK installed