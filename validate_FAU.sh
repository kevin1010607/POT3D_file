#!/bin/bash
#SBATCH --job-name=validate
#SBATCH --partition=work
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=72
#SBATCH --cpus-per-task=1

POT3D_HOME=$PWD
TEST="isc2023" # The kind of testcase

# echo "Number of nodes: $SLURM_NNODES"
# echo "Number of ranks per node: $SLURM_NTASKS_PER_NODE"
# echo "Number of threads per rank: $SLURM_CPUS_PER_TASK"

RANK_NUM=$(($SLURM_NNODES * $SLURM_NTASKS_PER_NODE))

BINDTO="core"
MAPBY="socket"

spack load intel-oneapi-compilers@2023.0.0
spack load intel-oneapi-mpi@2021.8.0
spack load hdf5@1.14.0%oneapi@2023.0.0

cp ${POT3D_HOME}/testsuite/${TEST}/input/* ${POT3D_HOME}/testsuite/${TEST}/run/
cd ${POT3D_HOME}/testsuite/${TEST}/run

# HDF5=$(spack find --path hdf5 | grep hdf5 | cut -d ' ' -f 3)
HDF5=$(dirname $(dirname $(which h5cc)))
export LD_LIBRARY_PATH="$HDF5/lib":$LD_LIBRARY_PATH

rm -f pot3d.err pot3d.log pot3d.out timing.out
echo "Running POT3D with ${SLURM_NNODES} nodes, ${SLURM_NTASKS_PER_NODE} MPI ranks per node, ${SLURM_CPUS_PER_TASK} threads per rank..."
mpirun -np ${RANK_NUM} \
    -bind-to ${BINDTO} \
    -map-by ${MAPBY} \
    ${POT3D_HOME}/bin/pot3d 1> pot3d.log 2>pot3d.err
echo "Done!"

runtime=($(tail -n 5 timing.out | head -n 1))
echo "Wall clock time:                ${runtime[6]} seconds"

#Validate run:
${POT3D_HOME}/scripts/pot3d_validation.sh pot3d.out ${POT3D_HOME}/testsuite/${TEST}/validation/pot3d.out
echo " "