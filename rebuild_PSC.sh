# HDF5=$(spack find --path hdf5 | grep hdf5 | cut -d ' ' -f 3)
HDF5=$(dirname $(dirname $(which h5cc)))

HDF5_INCLUDE_DIR="$HDF5/include"
HDF5_LIB_DIR="$HDF5/lib"
HDF5_LIB_FLAGS="-lhdf5_fortran -lhdf5_hl_fortran -lhdf5 -lhdf5_hl"
FFLAGS="-O3 -xHost -assume byterecl -heap-arrays"

POT3D_CUSPARSE=0
CCFLAGS="-O3"

POT3D_HOME=$PWD

cd ${POT3D_HOME}/src
echo "Making copy of Makefile..."
cp Makefile.template Makefile
echo "Modifying Makefile to chosen flags..."

sed -i "s#mpif90#mpiifort#g" Makefile
sed -i "s#<FFLAGS>#${FFLAGS}#g" Makefile
sed -i "s#<CCFLAGS>#${CCFLAGS}#g" Makefile
sed -i "s#<POT3D_CUSPARSE>#${POT3D_CUSPARSE}#g" Makefile
sed -i "s#<HDF5_INCLUDE_DIR>#${HDF5_INCLUDE_DIR}#g" Makefile
sed -i "s#<HDF5_LIB_DIR>#${HDF5_LIB_DIR}#g" Makefile
sed -i "s#<HDF5_LIB_FLAGS>#${HDF5_LIB_FLAGS}#g" Makefile
echo "Building POT3D...."

make 
echo "Copying POT3D executable from SRC to BIN..."
cp ${POT3D_HOME}/src/pot3d ${POT3D_HOME}/bin/pot3d
echo "Done!"

cd $POT3D_HOME