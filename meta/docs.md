# META job farming

Created: August 29, 2022 3:35 PM
Last modified: August 29, 2022 3:35 PM
Tags: Compute Canada, MATLAB

[META: A package for job farming](https://docs.alliancecan.ca/wiki/META:_A_package_for_job_farming)

# Table of contents

# Introduction

Some definitions to start:

- case = one independent calculation
- job = what you submit to the scheduler

From the docs,

> META has the following features:
> 
> - SIMPLE mode (one case per job) and META node (many cases per job).
> - Dynamic workload balancing in META mode.
> - Capture the exit status of all individual cases.
> - Automatically resubmit all the cases which failed or never ran.
> - Submit and independently operate multiple farms (groups of cases) on the same cluster.
> - Automatically run a post-processing job once all the cases have been processed successfully.

# A simple test farm

To start a test farm, run the following commands:

```html
module load meta-farm
farm_init.run test-farm
	-> Success!
```

At this point, you have a directory `test-farm/` which looks like

```html
test-farm/
    config.h
    job_script.sh
    resubmit_script.sh
    single_case.sh
    table.dat
```

This incredibly simple test farm does run as-is, and is a great resource for understanding how to build your own more complicated job.

## `table.dat`

The `table.dat` file provides the commands to be run in the job farm. In the test farm, each job is a simple random sleep time. You can see this in the table, where each line looks like

```html
N sleep ss
```

Where `N` is the job number and `ss` is a random integer between 10 and 60.

For a model that takes two parameters as input, the `table.dat` file would probably look something like

```html
1 run_model(x1, y1)
2 run_model(x2, y2)
...
N run_model(xN, yN)
```

## `single_case.sh`

This script is the actual computation that’s run. The section that’s intended to be modified is explicitly marked. The customizable section includes commands to create a jobid-sepcific directory and to directly evaluate each line in the `table.dat` file by default. This can be extensively modified to suit your purposes.

## `job_script.sh`

This is the usual job script. Update your computation time (see ???), resource account, and computational resources. Don’t modify the command `task.run`. For example, the job script may look like

```bash
#!/bin/bash
# Here you should provide the sbatch arguments to be used in all jobs in this serial farm
# It has to contain the runtime switch (either -t or --time):
#SBATCH --time=0-00:10
#SBATCH --mem=4G
#SBATCH --account=def-gflowers

# Don't change this line:
task.run
```

for the default farm.

## Running the farm

Run the farm using the `[submit.run](http://submit.run)` command. The farm can be run in the `SIMPLE` mode, where you run one case per job (i.e., this acts just like a [Slurm Job Arrays](https://www.notion.so/Slurm-Job-Arrays-92f4553115a241ac9e003f80e66bb23b)), or in the `META` mode, where many cases are run for each job (e.g., 10 scheduler jobs run 100 simulation cases). If you’re using META instead of job arrays, you probably want to take advantage of the `META` mode. Simple and META modes are run as

```bash
submit.run -1
```

```bash
submit.run N
```

## Example: SIMPLE

The test farm runs in either SIMPLE or META mode just fine. For SIMPLE mode, run `submit.run -1`. You’ll see a job array pop up in your queue. I.e., `sqm` looks something like

```markdown
JOBID      NAME  CPUS NODE MIN_MEM   ST            START_TIME              END_TIME    TIME_LEFT
43482868_  test-far     1    1      4G   PD                   N/A                   N/A        10:00
```

Once the job finishes, your directory will be quite busy:

```markdown
-rw-r----- 1 tghill tghill  691 Aug 29 10:29 config.h
-rwxr-x--- 1 tghill tghill  271 Aug 29 10:45 job_script.sh
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 MISC
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 OUTPUT
-rw-r----- 1 tghill tghill  209 Aug 29 10:29 resubmit_script.sh
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN1
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN10
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN11
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN12
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN13
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN14
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN15
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN16
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN17
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN18
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN2
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN3
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN4
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN5
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN6
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN7
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN8
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:48 RUN9
-rwxr-x--- 1 tghill tghill 1.6K Aug 29 10:44 single_case.sh
drwxr-x--- 2 tghill tghill 4.0K Aug 29 10:49 STATUSES
-rw-r----- 1 tghill tghill  207 Aug 29 10:39 table.dat
lrwxrwxrwx 1 tghill tghill   51 Aug 29 10:34 TMP -> /home/tghill/tmp/cedar5.cedar.computecanada.ca.5924
```

The new `RUNX` directories are a result of the `single_case.sh` script, which contains the line `mkdir -p RUN$ID`. For the default farm, these are all empty.

The `OUTPUT` directory contains the slurm output files, which look something like

```markdown
Case 12:
Exiting after processing one case (-1 option)
```

The `STATUSES` directory contains information about each job status. The `MISC` directory isn’t important at this point.

## Example: META

If you want to re-run the farm in META mode, first run `[clean.run](http://clean.run)` and enter `yes` at the prompt. This deletes all files created by running the farm and returns the directory to the like-new state.

Suppose we want to run the 18 cases with just 4 jobs. This is easy — run the farm using

```markdown
submit.run 4
```

The queue will look the same as last time; a job array is sitting in the queue, waiting to start. The first few directories have been made (`MISC/`, `OUTPUT/`, `STATUSES/`, and `TMP/`)

If you catch the queue while the job is running, it will look something like:

```markdown
JOBID      NAME  CPUS NODE MIN_MEM   ST            START_TIME              END_TIME    TIME_LEFT
43484840_  test-far     1    1      4G    R   2022-08-29T11:15:06   2022-08-29T11:25:06         8:20
43484840_  test-far     1    1      4G    R   2022-08-29T11:15:06   2022-08-29T11:25:06         8:20
43484840_  test-far     1    1      4G    R   2022-08-29T11:15:06   2022-08-29T11:25:06         8:20
43484840_  test-far     1    1      4G    R   2022-08-29T11:15:06   2022-08-29T11:25:06         8:20
```

## Output files

### Job Status

META conveniently provides the exit code of each job in the status output files, `STATUSES.status.JOBID`. These files contain two columns. The first is the case number, and the second is the exit code. E.g.,

```markdown
4 0
6 0
11 0
```

means that the first *job* has run *cases* 4, 6, and 11, and they have all exited normally.

### Slurm outputs

By default, the slurm output files go to the `OUTPUT/` directory. For the simple farm in META mode, these files might look like

```markdown
Case 2:
Case 7:
Case 10:
Case 14:
Case 17:
No cases left; exiting.
```

This file tells us that the first job ran 5 of the cases.

# A MATLAB test farm

<aside>
💡 This example goes through configuring the farm to run a parameter sweep with MATLAB.

</aside>

Suppose we have a MATLAB function, `mjob.m`, which takes three arguments: two parameters, `x` and `y`, and the job ID to save the output to a job-specific file:

```matlab
function mjob(x, y, jobid)
fout = sprintf('./RUN/output_%d.txt', jobid);
disp(fout)

result = x*y;
writematrix(result, fout);
```

To run the model with 9 parameter combinations, we can create the table

```markdown
1 mjob(0.1, 0.01, 1)
2 mjob(0.5, 0.01, 2)
3 mjob(0.9, 0.01, 3)
4 mjob(0.1, 0.05, 4)
5 mjob(0.5, 0.05, 5)
6 mjob(0.9, 0.05, 6)
7 mjob(0.1, 0.1, 7)
8 mjob(0.5, 0.1, 8)
9 mjob(0.9, 0.1, 9)
```

We also modify the `single_case.sh` script to remove the case-specific directories and to run the matlab file.

```bash
# ++++++++++++++++++++++  This part can be customized:  ++++++++++++++++++++++++
#  Here:
#  $ID contains the case id from the original table (can be used to provide a unique seed to the code etc)
#  $COMM is the line corresponding to the case $ID in the original table, without the ID field
#  $METAJOB_ID is the jobid for the current meta-job (convenient for creating per-job files)

# mkdir -p RUN$ID
# cd RUN$ID

echo "Case $ID:"

# Executing the command (a line from table.dat)
# It's allowed to use more than one shell command (separated by semi-columns) on a single line
eval "module load matlab/2020b; matlab -nodisplay -singlecompthread -r '$COMM; exit'"

# Exit status of the code:
STATUS=$?

# cd ..

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
```

The farm is run in META mode using 2 jobs for 9 cases,

```bash
submit.run 2
```

This job runs quickly, and the output files are all put in the `RUN` directory, `output_001.txt` through `output_009.txt`. The `OUTPUT/` directory contains the log files, which just have a lot of MATLAB headers in them really. The `STATUSES/` directory shows that the cases were split 5/4 between the two jobs, as we may have expected since each job runs in the same (short) amount of time.

# (Sub-)Glacial farming

The last step is to situate GlaDS within the META farm environment. Suppose we have a fresh farm, `glads-farm`. We want to run GlaDS with parameters given by the `glads_para_gamma_kc.txt` file, 

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

The strategy is to use the job ID to extract the appropriate row from this parameter file. This approach means the parameters don’t need to be explicitly listed in the `table.dat` file:

```bash
1 run_job(1)
2 run_job(2)
3 run_job(3)
4 run_job(4)
5 run_job(5)
6 run_job(6)
7 run_job(7)
8 run_job(8)
9 run_job(9)
```

The matlab function to run GlaDS is `run_job.m`,

```matlab
function run_job(jobid);
% run_job(jobid) runs GlaDS simulation number 'jobid'
%
% For integer jobid, run a simulation parameters given by
% row jobid in the parameter file "glads_para_gamma_kc.txt"

% String format the output filename
fout = sprintf('RUN/output_%03d.nc', jobid);

% Read parameter file
paraid = fopen('glads_para_gamma_kc.txt', 'r');
para = fscanf(paraid,'%f %f', [2 9])';
gamma = para(jobid, 1);
kc = para(jobid, 2);

% Run GlaDS
set_paths;
mesh_nr = 2;
pa = get_para_steady(mesh_nr, gamma, kc, fout);

% result = gamma*kc;
% writematrix(result, fout);
steady_out = run_model(pa);
```

Finally, the compute script is

```bash
#!/bin/bash
# The actual (serial) computation, for a single case No. $2 in the table $1.

TABLE1=$1
i1=$2

# Total number of cases:
## If the env. variable N_cases is defined, using it, otherwise computing the number of lines in the table:
if test -z $N_cases
  then
  N_cases=`cat "$TABLE1" | wc -l`
  fi

# Exiting if $i1 goes beyond $N_cases (can happen in bundled farms):
if test $i1 -lt 1 -o $i1 -gt $N_cases  
  then
  exit
  fi
  
# Extracing the $i1-th line from file $TABLE1:
LINE=`sed -n ${i1}p $TABLE1`
# Case id (from the original cases table):
ID=`echo "$LINE" | cut -d" " -f1`
# The rest of the line:
COMM=`echo "$LINE" | cut -d" " -f2-`

METAJOB_ID=${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}

# ++++++++++++++++++++++  This part can be customized:  ++++++++++++++++++++++++
#  Here:
#  $ID contains the case id from the original table (can be used to provide a unique seed to the code etc)
#  $COMM is the line corresponding to the case $ID in the original table, without the ID field
#  $METAJOB_ID is the jobid for the current meta-job (convenient for creating per-job files)

echo "Case $ID:"

# Executing the command (a line from table.dat)
# It's allowed to use more than one shell command (separated by semi-columns) on a single line
eval "module load matlab/2020b; matlab -nodisplay -r '$COMM; exit'"

# Exit status of the code:
STATUS=$?

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Saving all current metajob statuses to a single file with a unique name:
echo $ID $STATUS >> STATUSES/status.$METAJOB_ID
```

# Advanced features

The META scripts have some incredibly useful advanced features. Check them out on the Alliance Docs

[META: A package for job farming](https://docs.alliancecan.ca/wiki/META:_A_package_for_job_farming)

In particular, some potentially helpful features include:

- Automatically resubmitting jobs
- Automatically running post-processing
- MPI/GPU farming
- Advanced parsing of `table.dat`