function mjob(x, y, jobid)
fout = sprintf('./RUN/output_%d.txt', jobid);
disp(fout)

result = x*y;
writematrix(result, fout);
