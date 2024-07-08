
# install openmc with dagmc embree and double down
# packages are compiled in this install script using all available CPU cores.
# to reduce the core usage to 2 replace -j commands with -j2


sudo apt-get --yes update
sudo apt-get --yes upgrade


# install dependancies
sudo apt-get install libglfw3
sudo apt-get install -y libglfw3-dev
sudo apt-get install -y libopenblas-dev
sudo apt-get install -y libpng-dev
sudo apt-get install -y libeigen3-dev
sudo apt-get install -y git
sudo apt-get install -y wget
sudo apt-get install -y gfortran
sudo apt-get install -y g++
sudo apt-get install -y mpich
sudo apt-get install -y libmpich-dev
sudo apt-get install -y libhdf5-serial-dev
sudo apt-get install -y libhdf5-mpich-dev
sudo apt-get install -y hdf5-tools
sudo apt-get install -y imagemagick
sudo apt-get install -y cmake
sudo apt-get install -y libeigen3-dev
sudo apt-get install -y libnetcdf-dev
sudo apt-get install -y libtbb-dev
sudo apt-get install -y libgles2-mesa-dev

# install python dependancies, assumes conda ins installed
mamba install -y -c conda-forge numpy cython cad_to_dagmc

# installs embree
cd ~
git clone --shallow-submodules --single-branch --branch v3.12.2 --depth 1 https://github.com/embree/embree.git
cd embree
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=.. -DEMBREE_ISPC_SUPPORT=OFF
make -j
make -j install

# install moab and pymoab
cd ~
mkdir MOAB
cd MOAB
git clone --single-branch -b 5.5.1 --depth 1 https://bitbucket.org/fathomteam/moab/
mkdir build
cd build
apt-get install -y libeigen3-dev
cmake ../moab -DENABLE_PYMOAB=ON -DENABLE_HDF5=ON -DENABLE_BLASLAPACK=OFF -DENABLE_FORTRAN=OFF
make -j2
sudo make install


# add to new dirs to the path
echo 'export PATH="$HOME/MOAB/bin:$PATH"'  >> ~/.bashrc 
echo 'export LD_LIBRARY_PATH="$HOME/MOAB/lib:$LD_LIBRARY_PATH"'  >> ~/.bashrc 
source ~/.bashrc 

# install Double-Down
cd ~
git clone --shallow-submodules --single-branch --branch v1.1.0 --depth 1 https://github.com/pshriwise/double-down.git
cd double-down
mkdir build
cd build
cmake .. -DMOAB_DIR=$HOME/MOAB -DCMAKE_INSTALL_PREFIX=.. -DEMBREE_DIR=$HOME/embree
make -j
make -j install

# DAGMC version develop install from source
cd ~
mkdir DAGMC
cd DAGMC
git clone --single-branch --branch v3.2.3 --depth 1 https://github.com/svalinn/DAGMC.git
mkdir build
cd build
cmake ../DAGMC -DBUILD_TALLY=ON -DMOAB_DIR=/usr/local -DDOUBLE_DOWN=ON -DBUILD_STATIC_EXE=OFF -DBUILD_STATIC_LIBS=OFF -DCMAKE_INSTALL_PREFIX=$HOME/DAGMC/ -DDOUBLE_DOWN_DIR=$HOME/double-down
sudo make -j install

# add to new dirs to the path
echo 'export PATH="$HOME/DAGMC/bin:$PATH"'  >> ~/.bashrc 
echo 'export LD_LIBRARY_PATH="$HOME/DAGMC/lib:$LD_LIBRARY_PATH"'  >> ~/.bashrc 
source ~/.bashrc 

# installs OpenMC
cd ~
git clone --single-branch --branch develop --depth 1 https://github.com/openmc-dev/openmc.git
cd openmc
mkdir build
cd build
# compile without dagmc
# cmake ..
cmake -DOPENMC_USE_DAGMC=ON -DDAGMC_ROOT=$HOME/DAGMC -DHDF5_PREFER_PARALLEL=off -DOPENMC_USE_MPI=ON -DHDF5_PREFER_PARALLEL=ON -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_C_COMPILER=mpicc .. 
make -j
make -j install
cd ..
pip install .
