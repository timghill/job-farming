function run_job(jobid);
% run_job(jobid) runs GlaDS simulation number 'jobid'
%
% For integer jobid, run a simulation parameters given by
% row jobid in the parameter file "glads_para_gamma_kc.txt"

% String format the output filename
fout = sprintf('output_%03d.nc', jobid);

% Read parameter file
paraid = fopen('para.txt', 'r');
para = fscanf(paraid,'%f %f');
gamma = para(jobid);

% Run GlaDS
set_paths;
mesh_nr = 2;
pa = get_para_steady(mesh_nr, gamma, fout);

% result = gamma*kc;
% writematrix(result, fout);
steady_out = run_model(pa);
