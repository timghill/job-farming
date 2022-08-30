function run_job(jobid);

fout = sprintf('RUN/output_%03d.nc', jobid);

% Read parameter file
paraid = fopen('glads_para_gamma_kc.txt', 'r');
para = fscanf(paraid,'%f %f', [2 9])';
gamma = para(jobid, 1);
kc = para(jobid, 2);

% Run the 'simulation' -- this would be replaced by some expensive model
result = gamma*kc;

writematrix(result, fout);
