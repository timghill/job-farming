function para = get_def_para()
% para = get_def_para();
%
% Returns the default parameters to run the box runs.
% 
% If you have a suite of similar model runs it often is good to have a
% default parameter file from which all the others are derived.  Then,
% if you decide to change something for all model runs, it only needs
% to be done here.

para = get_default_para();
[pm, pn, pin, ps, pst, psp, mesh, dmesh, pp, pt, psin, pmd, psmd, pcm] = unwrap_all_para(para);
clear para;

%% Model description
% a descriptive string for the model-run
pm.model_run_descript = ['Box defaults'];
% save-file root (empty means no saveing)
pm.save_filename_root = '';
% save the model every so often
pm.backup_time_steps = 1000;
% IC from previous model run?
pm.IC_from_file = 0;

% TIME
%%%%%%
pt.start = 0;        % start time
pt.end   = 100*pp.day;  % end time
pt.out_t = pt.start:5*pp.day:pt.end;

% MODEL
%%%%%%%

% how much output will be given
pm.verbosity = 2;
pm.plot_verbosity = 0;

% git revision of model runs dir
pm.git_revision_model_runs = strtrim(git('rev-parse --verify HEAD'));

%% some directories (not added to matlab path
% set all relative to either pm.dir.model_runs or pm.dir.glads
[~, dir_of_this_mfile] = get_mfile_name();
pm.dir.model_runs = dir_of_this_mfile;
pm.dir.data = ['./', 'data', '/'];
% directory to save model output
pm.dir.model_save = ''; % to be set


%% paths (which will be added to the matlab path)
% all paths in pm.path will be added to the matlab path (unless ==[])

% path of sourceterm functions
pm.path.sourceterm_fns = [pm.dir.glads, 'forcings_and_BCs', '/'];
% path of topography functions
pm.path.topo_fns = [pm.dir.data, 'topo_x_squared_para', '/'];
% ICs
% directory of IC functions
pm.path.IC_fns = [];
% directory of BC functions
pm.path.BC_fns = [];


%% some file names
% the path and name of problem specific parameter mfile (to be set there)
pm.file.para_mfile = add_mfile_name_to_cellarr(pm.file.para_mfile);  %this is a cell array with all the parameter m-files
% mesh file
pm.file.mesh = [pm.dir.data, 'mesh_1/mesh.mat'];


% MESH
%%%%%%
dmesh = load(pm.file.mesh);
% get desired mesh out (thanks to matlab's syntax this is butt-ugly)
fns = fieldnames(dmesh);
dmesh = getfield(dmesh,fns{1});
dmesh = dmesh{1}; 

%  PYHSICAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%

pp.cond_s = 5e-3;  %  conductivity of sheet (1e-2)
pp.cond_c = 1e-1;  %  conductivity of channels (1e-1)

pp.l_c = pp.l_bed;

% topo
% pp.z_offset_ice_thickness = 0; % to avoid infinity slop at ice margin, start with a ice cliff of this height.
% max_surf_ele = 1600;
% glacier_len = dmesh.x_extent(2);
% pp.topo.surf_sqrt_factor = max_surf_ele/sqrt(glacier_len);  % max surface elevation in m
% pp.topo.bed_slope = 0/100e3;  % bed slope


%% source term parameters
% A source of 0.1/pp.day corresponds to 3400 m^3/s over the 100x30km^2 catchment

% discharge in m/s
pp.s_terms_s.start_t    = 0*pp.day;
pp.s_terms_s.end_t_ramp = 0*pp.day;
pp.s_terms_s.start_val  = 0.01/pp.day;
pp.s_terms_s.mean_val   = 0.01/pp.day;  
pp.s_terms_s.amp_r        = 0;
pp.s_terms_s.period     = pp.day;

% discharge in m^3/s
pp.s_terms_c.start_t    = 0*pp.day;
pp.s_terms_c.end_t_ramp = 1*pp.day;
pp.s_terms_c.start_val  = 0/pp.day;
pp.s_terms_c.mean_val   = 0/pp.day;
pp.s_terms_c.amp_r        = 0;
pp.s_terms_c.period     = pp.day;



%  NUMERICAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%
steppers = {'fEuler', 'ode113', 'adaptive', 'ode15i', 'ode15s'};
pn.ts.stepper =  steppers{4};

% SCALEd PARAMETERS
%%%%%%%%%%%%%%%%%%%%


%% INPUT FUNCTIONS
%%%%%%%%%%%%%%%%%

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

%% Geometry and derived (constant) function
% these are all functions of xy and time only
pin.bed_elevation = make_anon_fn('@(xy, time) double(bed_elevation_para(xy, time))');
pin.ice_thickness = make_anon_fn('@(xy, time) double(ice_thickness_para(xy, time))');

%% Source functions
pin.source_term_s = make_anon_fn('@(xy,time) double(source_term_para(xy, time, pp.s_terms_s))', pp);
tmpvec = zeros(dmesh.tri.n_nodes,1);
pin.source_term_c = make_anon_fn('@(time) double(source_term_para(tmpvec,time, pp.s_terms_c))', tmpvec, pp);


%% Storage terms: no storage
% englacial storage (set to zero)
pin.sigma = make_anon_fn('@(xy, time) double(xy(:,1).*0 )');  % englacial void ratio 

% SCALING PARAMETERS
%%%%%%%%%%%%%%%%%%%%
% now that we have the dmesh we can get the length scale
ps.x = 0.5*(abs(diff(dmesh.x_extent)) + abs(diff(dmesh.y_extent))); % length (m)
ps.x_offset = dmesh.x_extent(1);
ps.y_offset = dmesh.y_extent(1);

% the rest of the scales are calculated:
ps = set_default_scales(ps, pp, dmesh);
% if any scales are to be changed from what set_default_scales sets
% them to do this here:

% SCALE EVERYTHING
%%%%%%%%%%%%%%%%%%
% scaling of the rest
[psp, pst, psmd, psin, mesh] = scale_para(pp, pt, pmd, pin, dmesh, ps);

% END
%%%%%
para = wrap_para(pm, pn, pin, ps, pt, pst, psp, pp, mesh, dmesh, psin, pmd, psmd, pcm);
