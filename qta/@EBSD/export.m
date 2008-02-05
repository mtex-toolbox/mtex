function export(ebsd,fname,varargin)
% export EBSD data to a ascii file
%
%% Input
%  ebsd - @ebsd
%  fname - filename
%
%% Options
%  BUNGE   - Bunge convention (default)
%  ABG     - Matthies convention (alpha beta gamma)
%  DEGREE  - output in degree (default)
%  RADIANT - output in radiant

G = [ebsd.orientations];
q = quaternion(G);

[a,b,g] = quat2euler(q,'Bunge');
d = [a(:),b(:),g(:)]; 

if ~check_option(varargin,'radiant')
  d = d ./ degree; %#ok<NASGU>
end

save(fname,'d','-ASCII');
