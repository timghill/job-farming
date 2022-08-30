# Slurm Job Arrays

Created: August 29, 2022 10:17 AM
Property: August 29, 2022 10:17 AM
Tags: Compute Canada

> If your work consists of a large number of tasks which differ only in some parameter, you can conveniently submit many tasks at once using a *job array,* also known as a *task array*
 or an *array job*. The individual tasks in the array are distinguished by an environment variable, `$SLURM_ARRAY_TASK_ID`, which Slurm sets to a different value for each task
> 

[https://docs.alliancecan.ca/wiki/Job_arrays](https://docs.alliancecan.ca/wiki/Job_arrays)

# Introduction

Job Arrays are one option for scheduling a large number of related jobs (see also: [META job farming](https://www.notion.so/META-job-farming-51beb32b276a4d2f809807ec05401eb9)). Job arrays are primarily beneficial in terms of convenience, rather than in terms of computational resources. From the docs,

> Note that, other than the initial job-submission step with `sbatch`, the load on the scheduler is the same for an array job as for the equivalent number of non-array jobs. The cost of dispatching each array task is the same as dispatching a non-array job.
> 

Job Arrays work by specifying a range of “Job IDs” in the scheduler file:

```bash
#SBATCH --array=X-Y
```

and for each job ID within the specified range, it runs the command(s) in the scheduler file with the environment variable `$SLURM_ARRAY_TASK_ID`.

# Example

Suppose we want to do a parameter sweep for a numerical model. We list the parameters we want to run in a text file called `para.txt`:

```markdown
1.000000000000000056e-01 1.000000000000000021e-02
5.000000000000000000e-01 1.000000000000000021e-02
9.000000000000000222e-01 1.000000000000000021e-02
1.000000000000000056e-01 5.000000000000000278e-02
5.000000000000000000e-01 5.000000000000000278e-02
9.000000000000000222e-01 5.000000000000000278e-02
1.000000000000000056e-01 1.000000000000000056e-01
5.000000000000000000e-01 1.000000000000000056e-01
9.000000000000000222e-01 1.000000000000000056e-01
```

The slurm script could look something like

```bash
#!/bin/bash
#SBATCH --time=00-00:05:00    # Replace by some more realistic computation time
#SBATCH --array=1-9           # We have 9 parameter combinations
#SBATCH --account=def-gflowers
#SBATCH --ntasks=1            # Resources *per job*
#SBATCH --mem-per-cpu=4G      # Resources *per job*

echo "Starting task $SLURM_ARRAY_TASK_ID"

module load matlab/2020b
matlab -nodisplay -r 'mjob($SLURM_ARRAY_TASK_ID)'
```

where the matlab script `mjob.m` takes in one parameter (the job ID). In this model it’s the matlab script `mjob.m` that reads the parameter file. It’s also possible to read the parameters with something like `sed`.

```matlab
function mjob(jobid)
% mjob(jobid) runs the specified job number
% 
% mjob reads the specified line from the parameter file `para.txt`
% and runs the simulation

disp(jobid)

% Read parameter file
paraid = fopen('para.txt', 'r');
para = fscanf(paraid,'%f %f', [2 9])';
x = para(jobid, 1);
y = para(jobid, 2);

% Run the 'simulation' -- this would be replaced by some expensive model
result = x*y;

% Write the outputs to a file named by the job id
fname = sprintf('outputs/output_%d.txt', jobid);
writematrix(result, fname);
```

As usual, the job is submitted to the scheduler:

```bash
sbatch array.sh
```

After the job runs, the directory will look like:

```html
/
  array.sh
  mjob.m
  outputs/
    output_1.txt
		...
		output_2.txt

  para.txt
  slurm-43481675_1.out
	...
  slurm-43481675_9.out
```

and each `output_N.txt` file contains a single line with the result `x * y`. The slurm output files have the usual Matlab header and the job ID.
