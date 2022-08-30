#!/bin/bash
# Here you should provide the sbatch arguments to be used in all jobs in this serial farm
# It has to contain the runtime switch (either -t or --time):
#SBATCH --time=0-00:10
#SBATCH --mem=4G
#SBATCH --account=def-gflowers

# Don't change this line:
task.run
