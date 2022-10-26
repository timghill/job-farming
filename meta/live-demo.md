# Live job-farming demo with META

SFUGG group meeting, 2022-10-27

Before we get started, some terminology:

 * A **case** refers to one simulation task
 * A **job** refers to one task on the cluster's scheduler

For example, you might run your model with 1000 parameter combinations, using 24 CPUs. This means you are running 1000 **cases** using 24 **jobs**.

For more information on META job farming, see the [Alliance Can Docs](https://docs.alliancecan.ca/wiki/META:_A_package_for_job_farming).

## Initialize the farm

Run

```
farm_init.run [farm_name]
```

For this case, use:

```
farm_init.run live-demo
```

Now you have a farm template! Go check it out.

## Run the minimal example
The farm is initialized with a basic working example. Let's see how this works.

 * `config.h`: Cluser-specific configuration file for the farm. You don't need to modify this.
 * `job_script.sh`: This is where you put in your CPU and time requirements, and your account name. We will modify this below.
 * `resubmit_script.sh`: Don't worry about this for now
 * `single_case.sh`: This is the script that is run for each simulation case.
 * `table.dat`: A list of cases to run.

### Check the CPU requirements and change the account name

Open `job_script.sh` and update the account to `def-gflowers`. The time is for each **job**, not each case. If you expect each case to take 1 hour and you expect each job to run about 12 cases, you should set the run time to at least 12 hours.

### Run the farm!

The META farm is run using the command `submit.run [n]` where `n` controls the number of jobs (CPUs) to request. `n = -1` requests the same number of jobs as cases. More commonly you will set `n` less than the number of cases. For this case, let's see what happens using 2 jobs:

```
submit.run 2
```

The scripts will tell you that the farm was successfully submitted, and you should see the jobs in your queue.

Check your working directory, and you'll see a few new directories have been made: `MISC`, `OUTPUT`, `STATUSES`, `TMP`, and, for this configuration, a `RUN{i}` directory for each case 1<= i <= 18.

## Make a more interesting example

Suppose we have a bash script `run_job.sh` that runs our simulation. `run_job.sh` takes two arguments, a and b, representing two simulation parameters that we are varying. Use the following mock script, `run_job.sh`:

```
#!/usr/bin/bash

# A simple script to mimic running a simulation
#
# Requires two inputs
#   a : float
#   b : float
#
# Echos the simulation parameters and writes the result
# of the simulation (a * b)

echo "Running simulation with parameters a = ${2} and b = ${3}"

ans=$(bc -l <<<"${2}*${3}")

echo "${ans}" > "RUN${1}/output.txt
```

Suppose we do a small one-at-a-time parameter sweep. Use the following table, `table.dat`:

```
1 ./run_job.sh 0.1 0.1
2 ./run_job.sh 0.1 0.5
3 ./run_job.sh 0.1 1
4 ./run_job.sh 0.5 0.1
5 ./run_job.sh 0.5 0.5
6 ./run_job.sh 0.5 1
7 ./run_job.sh 1 0.1
8 ./run_job.sh 1 0.5
9 ./run_job.sh 1 1
```

We have to make one update to the script `single_case.sh`. Since our job script lives in the root, let's copy it into the job directories and run it from there. This means changing the customizable section to:

```
mkdir -p RUN$ID
cp run_job.sh RUN$ID/
cd RUN$ID

eval "./$COMM; sleep 15"
STATUS=$?
cd ..
```

Finally, we can run this farm. The jobs are super short so we may as well run it in serial mode:

```
submit.run 1
```
