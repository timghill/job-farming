%% Place moulins on triangular mesh and compute catchments
%
% Discretizes a maximin optimized latin hypercube sample with a specified
% number of points to approximate uniformly spaced moulins.
%
% Computes a *heuristically gradient-weighted* distance metric to
% approximate moulin catchments.

%% Parameters

n_moulin = 30;
mesh_nr = 4;

rng(10) % For reproducibility

meshes = load('../mesh_1/mesh.mat');
dmesh = meshes.meshes{mesh_nr};

% LH design
lh = lhsdesign(n_moulin, 2, 'Criterion', 'maximin', 'Iterations', 100);
mx_exact = 100e3*lh(:, 1);
my_exact = 25e3*lh(:, 2);

% Distance matrix between exact moulins and each node.
moulin_dists = (mx_exact - dmesh.tri.nodes(:, 1)').^2 + (my_exact - dmesh.tri.nodes(:, 2)').^2;
[~, ii_moulin] = min(moulin_dists, [], 2);
mx = dmesh.tri.nodes(ii_moulin, 1);
my = dmesh.tri.nodes(ii_moulin, 2);

% Plot exact vs mesh-constrained moulins
figure
hold on
plot(mx_exact, my_exact, 'bo')
plot(mx, my, 'ro')
legend({'LHS Exact', 'Nodes'})

%% Compute distances
% Cartesian x-y distance matrix
d2_matrix = sqrt((dmesh.tri.nodes(:, 1) - dmesh.tri.nodes(ii_moulin, 1)').^2 + (dmesh.tri.nodes(:, 2) - dmesh.tri.nodes(ii_moulin, 2)').^2);

% Surface elevation
z = 6*(sqrt(dmesh.tri.nodes(:, 1) + 5e3) - sqrt(5e3)) + 1;

% Vertical displacement matrix
dz_matrix = z - z(ii_moulin)';

% Heuristic weighting
weight_matrix = d2_matrix - 35*dz_matrix;
[dmin, ixmin] = min(weight_matrix, [], 2);

% Plot catchments
figure
hold on
trisurf(dmesh.tri.connect, dmesh.tri.nodes(:, 1), dmesh.tri.nodes(:, 2), 0*ixmin, ixmin)
cmocean('phase')
hold on
axis image

plot(dmesh.tri.nodes(ii_moulin, 1), dmesh.tri.nodes(ii_moulin, 2), 'ko', 'MarkerFaceColor', 'k')

%% Statistics
% Compute catchment areas
catch_areas = zeros(n_moulin, 1);
for ii=1:n_moulin
    catch_areas(ii) = sum(dmesh.tri.area(ixmin==ii));
end

%% Save results
moulin = struct;
moulin.indices = ii_moulin;
moulin.xy = dmesh.tri.nodes(ii_moulin, :);
moulin.catchments = ixmin;
moulin.catchment_areas = catch_areas;

save(sprintf('moulins_mesh_%d.mat', mesh_nr), '-struct', 'moulin')