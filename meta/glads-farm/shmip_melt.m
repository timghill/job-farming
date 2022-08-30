function melt = shmip_melt(z, t, diurnal)
% SHMIP_MELT calculates surface runoff using the SHMIP parameterization
%
% melt = shmip_melt(z, t, diurnal);
%
% To use in the SaDS model, set
%
% z = shmip_elevation(dmesh.tri.elements);
% zc = shmip_elevation(dmesh.tri.edge_midpoints):
% params.ms = @(t) shmip_melt(z, t);
% params.msc = @(t) shmip_melt(zc, t);
%
% See also shmip_elevation

%% Parameters
day = 86400;            % One day in seconds
year = 31536000;        % One year in seconds
DDF = 0.01/86400;       % Degree day factor (m/K/s)
lr = -0.0075;           % Lapse rate (K/m)
DT = 0;                 % Simulate case "D3"

if diurnal
    ra = 1;                 % Relative amplitude of diurnal forcing
else
    ra = 0;
end

%% Parameterizations

% Temperature function (seasonal)
% temp = @(t) -16*cos(2*pi*t/year) - 5 + DT;
% temp = @(t) 10;
temp = 5;

% Diurnal variation
% diurnal = @(t) max(0, 1 - ra*cos(2*pi*t/day));

% runoff_diurnal = @(z, t) max(0, (z*lr + temp(t))*DDF.*diurnal(t));
% melt = runoff_diurnal(z, t);

melt = DDF*(z*lr + temp);
melt(melt<0) = 0;
end

