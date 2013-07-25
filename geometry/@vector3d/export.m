function export(v,fname,varargin)

[th,rh] = polar(v);
rp = reshape(mod([th,rh],2*pi),sum(length(v)),2);
if check_option(varargin,'DEGREE'), rp = rp / degree;end %#ok<NASGU>

save(fname,'rp','-ascii');
