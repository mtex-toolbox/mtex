function save(S2G,fname,varargin)

[th,rh] = polar(S2G);
rp = reshape(mod([th,rh],2*pi),sum(numel(S2G)),2);
if check_option(varargin,'DEGREE'), rp = rp / degree;end %#ok<NASGU>

save(fname,'rp','-ascii');
