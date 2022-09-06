"""
Automatically write table.dat file
"""

import numpy as np

para_file = 'para.txt'
table_file = 'table.dat'

para = np.loadtxt(para_file)

output_str = ''
_line_template = '%d run_job(%d)'

output_str = _line_template % (1, 1)
for i in range(2, len(para)+1):
    output_str = output_str + '\n' + _line_template % (i, i)

output_str = output_str + '\n'
with open(table_file, 'w') as table_handle:
    table_handle.writelines(output_str)

