# Job arrays

This directory describes running a large number of jobs using slurm job arrays. For complete documentation, see [`docs.md`](docs.md). This README will act as a quick start guide.

This directory runs a simple matlab function, [`mjob.m`](mjob.m), with parameter combinations given by the text file [`para.txt`](para.txt). Most of the machinery of the job arrays is contained in the job script, [`array.sh`](array.sh). The jobs are run simple by submitting the job script,

```bash
sbtach array.sh
```
