#!/bin/bash
#SBATCH --time=00-00:05:00
#SBATCH --array=1-9
#SBATCH --account=def-gflowers
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=4G

echo "Starting task $SLURM_ARRAY_TASK_ID"

module load matlab/2020b
# echo 'mjob([$(sed -n "${SLURM_ARRAY_TASK_ID}p" para.txt) $SLURM_ARRAY_TASK_ID])'
# matlab -nodisplay -r 'mjob([$(sed -n "${SLURM_ARRAY_TASK_ID}p" para.txt) $SLURM_ARRAY_TASK_ID])'
matlab -nodisplay -r 'mjob($SLURM_ARRAY_TASK_ID)'
