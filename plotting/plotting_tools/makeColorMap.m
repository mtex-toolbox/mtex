function makeColorMap(N)

if nargin == 0, N = 24; end

old = get(0,'DefaultAxesColorOrder');

fun = @(m)sRGB_to_OSAUCS(m,true,true);
rgb = maxdistcolor(N,fun,'inc',old, 'Lmin',0.4, 'Lmax',0.95,'CMax',0.6);

save(fullfile(mtex_path,'plotting','plotting_tools','colors.mat'),'rgb');

end