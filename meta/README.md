# META job farming

META is a more advanced (and more efficient!) way to submit a large number of jobs, especially if each job is "short" (i.e., takes much less than a day). This directory has three cases:

 1. [`test-farm/`](test-farm/), the default farm created by running `farm_init.run`.
 2. [`matlab-farm/`](matlab-farm/), a META farm for running a generic matlab farm.
 3. [`glads-farm`][glads-farm/), a META farm for running an ensemble of GlaDS simulations.

For a writeup of each farm, see [`docs.md`](docs.md).
