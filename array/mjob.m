function mjob(jobid)
disp(jobid)

paraid = fopen('para.txt', 'r');
para = fscanf(paraid,'%f %f', [2 9])';
x = para(jobid, 1);
y = para(jobid, 2);
result = x*y;
fname = sprintf('outputs/output_%d.txt', jobid);
writematrix(result, fname);
