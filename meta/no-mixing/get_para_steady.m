function para = get_para_steady(mesh_nr, alpha, beta, output)
% para = get_para_steady(mesh_nr);
%
% Returns the parameters to run the shmip to steady state under
% constant sheet input.
%
% If you want to plot the topography run
% >> plot_topo_on_grid(gca, para, 50,50)
% afterwards

% get the default parameters from get_shmip_def_para and modify them
addpath('../')
para = get_def_para();
rmpath('..')
[pm, pn, pin, ps, pst, psp, mesh, dmesh, pp, pt, psin, pmd, psmd, pcm] = unwrap_all_para(para);
clear para mesh dmesh; % so we don't mess up

%% Model description
% a descriptive string for the model-run
pm.model_run_descript = ['Run with steady forcing'];
% save-file root

% TIME
%%%%%%
pt.end   = 10*pp.year;  % end time
pt.out_t = pt.start:0.1*pp.year:pt.end;

% for forward Euler
pt.fEuler.dt    = 12 * pp.hour; % time step, set to NaN if not constant
pt.fEuler.dts   = pt.start:pt.fEuler.dt:pt.end; % the time steps for forward Euler (not needed for ode113 or adaptive)
% timesteps when output is stored:
pt.fEuler.out_t_inds = find_out_t_inds(pt.out_t, pt.fEuler.dts); % needed for forward Euler but not for ode113 or adaptive

% MODEL
%%%%%%%

%% some directories (not added to matlab path
% directory to save model output
[~, dir_of_this_mfile] = get_mfile_name();
pm.dir.model_save = [dir_of_this_mfile, 'RUN', '/'];
pm.save_filename = [pm.dir.model_save, output];
%% paths (which will be added to the matlab path)
% all paths in pm.path will be added to the matlab path (unless ==[])

%% some file names
% the path and name of problem specific parameter mfile (to be set there)
pm.file.para_mfile = add_mfile_name_to_cellarr(pm.file.para_mfile);  %this is a cell array with all the parameter m-files

% ADD the paths
add_paths(pm.path);

% MESH
%%%%%%
dmesh = load(pm.file.mesh);
% get desired mesh out (thanks to matlab's syntax this is butt-ugly)
fns = fieldnames(dmesh);
dmesh = getfield(dmesh,fns{1});
dmesh = dmesh{mesh_nr};

%  PYHSICAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%

pp.cond_c = 0.05;
pp.flags.max_S = 500; % limit to channel cross-sectional area for stability

cond = 1e-3;
pp.cond_s = cond;
pp.alpha_s = alpha;
pp.beta_s =  beta;

pp.l_bed = 2;
pp.l_c = 2;
pp.h_bed = 0.1;

% pp.alpha_s = 3;
% pp.beta_s = 2;

pp.float_frac = 0; % used below for BC

%% source term parameters
% A source of 0.1/pp.day corresponds to 3400 m^3/s over the 100x30km^2 catchment

% discharge in m/s
pp.s_terms_s.start_t    = 0*pp.day;
pp.s_terms_s.end_t_ramp = 0*pp.day;
pp.s_terms_s.start_val  = 0.01/pp.day;
pp.s_terms_s.mean_val   = 0.01/pp.day;  
pp.s_terms_s.amp_r      = 0;
pp.s_terms_s.period     = pp.day;

% discharge in m^3/s
pp.s_terms_c.start_t    = 0*pp.day;
pp.s_terms_c.end_t_ramp = 1*pp.day;
pp.s_terms_c.start_val  = 0/pp.day;
pp.s_terms_c.mean_val   = 0/pp.day;
pp.s_terms_c.amp_r      = 0;
pp.s_terms_c.period     = pp.day;


%  NUMERICAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%
pn.zero_channels_on_boundary = 1;
steppers = {'fEuler', 'ode113', 'adaptive', 'ode15i', 'ode15s'};
pn.ts.stepper =  steppers{5};

% $$$ pn.ts.adaptive.min_dt = 1e-6; % min time step in units of scaled time (1e-6)
% $$$ pn.ts.adaptive.abstol = 1e-6; % value below which solution is not
% $$$                               % considered for error analysis anymore (1e-4)
% $$$ pn.ts.adaptive.reltol = 1e-4; % relative error tolerance (1e-2)

sub_stepper = {'fEuler', 'leapfrog'};
pn.ts.adaptive.sub_stepper = sub_stepper{2}; % whether to use a leapfrog or forward Euler step (2)
pn.ts.adaptive.time_step_print = false; % if set to true then it
                                         % prints the taken time step

st = {'ode15s', 'ode23s', 'ode23t', 'odebim'};  % can also use ode23t, ode23s but ode15s is probbaly best
pn.ts.ode15s.stepper = st{1};


% SCALEd PARAMETERS
%%%%%%%%%%%%%%%%%%%%
% special parameters of this model run
psp.float_frac = pp.float_frac;  % floatation fraction used in dirichlet BC


%% INPUT FUNCTIONS
%%%%%%%%%%%%%%%%%

% NOTE: if parameters get redefined, then the anonymous functions need
% to be defined again to pick up the new parameters.

%% BC
% Dirichlet BC for phi: applied at nodes where bmark is odd
pin.bc_dirichlet_phi = make_anon_fn('@(xy, time, bmark, phi_0, phi_m) double(pp.float_frac * (phi_0-phi_m) + phi_m)', pp);
% Flux BC for phi and h_w: i.e. set phi or h_w such that this flux is
% given. Applied at edges where bmark_edge is even
% zero flux:
pin.bc_flux = make_anon_fn('@(xy, time, bmark_edge) double(zeros(sum(~logical(mod(bmark_edge,2)) & bmark_edge>0),1))');

%% IC 
% initial sheet thickness
pin.ic_h = make_anon_fn('@(xy, time) double(0.05 + 0*xy(:,1))');
% initial channel cross sectional area
pin.ic_S =  make_anon_fn('@(xy, time) double(0.0 + 0*xy(:,1))');

%% Source functions
pin.source_term_s = make_anon_fn('@(xy,time) double(source_term_shmip(xy, time, pin))', pin);
tmpvec = zeros(dmesh.tri.n_nodes,1);
pin.source_term_c = make_anon_fn('@(time) double(source_term_para(tmpvec,time, pp.s_terms_c))', tmpvec, pp);

%% Storage terms: no storage
% englacial storage (set to zero)
pin.sigma = make_anon_fn('@(xy, time) double(xy(:,1).*1e-5 )');  % englacial void ratio 


% SCALE EVERYTHING
%%%%%%%%%%%%%%%%%%

% now that we have the dmesh we can get the length scale
ps.x = 0.5*(abs(diff(dmesh.x_extent)) + abs(diff(dmesh.y_extent))); % length (m)
ps.x_offset = dmesh.x_extent(1);
ps.y_offset = dmesh.y_extent(1);

% the rest of the scales are calculated:
ps = set_default_scales(ps, pp, dmesh);
% if any scales are to be changed from what set_default_scales sets
% them to do this here:

% scaling of the rest
[psp, pst, psmd, psin, mesh] = scale_para(pp, pt, pmd, pin, dmesh, ps);

% END
%%%%%
para = wrap_para(pm, pn, pin, ps, pt, pst, psp, pp, mesh, dmesh, psin, pmd, psmd, pcm);
