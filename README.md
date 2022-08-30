# Job Farming for the national clusters

Running large ensembles of reasonably expensive simulations is not as trivial as it sounds. Of course, it is possible to launch N independent jobs with the scheduler, using N processor cores. We could also launch N/m jobs over N/m independent CPUs, where each job runs m cases. The national clusters, however, come with some built-in software and scripts to make this easier and, more importantly, more efficient.

Some quick definitions: a "job" refers to a single call to the scheduler. A "case" refers to a single simulation/computation. For example, if we want to run a model with 100 parameter combinations, we need to run 100 "cases". This could be run as 100 "jobs", or as N "jobs", where each job runs more than 1 case.

The code here provides examples of software to run a large number of cases using two different software packages. The `array/` directory uses [slurm job arrays](https://docs.alliancecan.ca/wiki/Job_arrays), while the `farming/` directory uses [META job farming](https://docs.alliancecan.ca/wiki/META:_A_package_for_job_farming). Each has their own documentation.
