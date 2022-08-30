function melt = source_term_shmip(xy, time, pin)
bed = pin.bed_elevation(xy, time);
thick = pin.ice_thickness(xy, time);
z = bed + thick;

diurnal = 0;
melt = shmip_melt(z, time, diurnal);

tstart = 0;
tend = 300*86400;

ramp = (time - tstart)/(tend-tstart);
ramp = max(0, min(1, ramp));

melt = melt * ramp  + 0.0025/86400/365;

% melt = 0.01/86400 * ones(size(xy(:, 1)));
end