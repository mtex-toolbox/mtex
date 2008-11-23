function export(ebsd,fname,varargin)
% export EBSD data to a ascii file
%
%% Input
%  ebsd - @EBSD
%  fname - filename
%
%% Options
%  BUNGE   - Bunge convention (default)
%  ABG     - Matthies convention (alpha beta gamma)
%  DEGREE  - output in degree (default)
%  RADIANS - output in radians

G = [ebsd.orientations];
q = quaternion(G);

[a,b,g] = quat2euler(q,'Bunge');
d = [a(:),b(:),g(:)]; 

if ~check_option(varargin,{'radians','radiant','radiand'})
  d = d ./ degree; 
end

if ~isempty(ebsd.xy), d = [d,ebsd.xy]; end %#ok<NASGU>

save(fname,'d','-ASCII','-single');
