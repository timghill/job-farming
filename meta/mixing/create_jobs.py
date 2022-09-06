"""
Put parameters from given parameter file into the submit script template
"""

import numpy as np

para_file = 'glads_para_gamma_kc.txt'
template_file = 'TEMPLATE_submit.txt'
submit_script = 'submit_jobs.sh'
output_pattern = 'submit_%03d.sh'

static_keyvals = {'{NAME}':'glads_ensemble',
    '{TIME}':'00-01:00:00'}

# Read the template str
with open(template_file, 'r') as template:
    template_str = template.readlines()

# Replace static values (eg job name, time)
output_str = template_str.copy()
for i, line in enumerate(output_str):
    for key in static_keyvals.keys():
        output_str[i] = output_str[i].replace(key, static_keyvals[key])

glads_para = np.loadtxt(para_file)
glads_para_keys = ['{GAMMA}', '{KC}']

for j in range(len(glads_para)):
    output_str_j = output_str.copy()
    for i in range(len(output_str)):
        for npara in range(len(glads_para_keys)):
            output_str_j[i] = output_str_j[i].replace(glads_para_keys[npara], glads_para[j][npara].astype(str))

            output_str_j[i] = output_str_j[i].replace('{NUM}', '%03d' % j)

    outfile = output_pattern % j
    with open(outfile, 'w') as output:
        output.writelines(output_str_j)

print('Wrote %d submit scripts to "%s"' % (len(glads_para), output_pattern))

"""
Create a script that runs all the submit scripts
"""

header = "#!/bin/bash\n"
outstr = header + '\n'
for i in range(len(glads_para)):
    outstr =  outstr + 'sbatch ' +  output_pattern%i + '\n'


with open(submit_script, 'w') as submitfile:
    submitfile.writelines(outstr)

print('Wrote script to submit jobs "%s"' % submit_script)
