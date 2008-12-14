function export(ebsd,fname,varargin)
% export EBSD data to a ascii file
%
%% Input
%  ebsd - @EBSD
%  fname - filename
%
%% Options
%  QUATERNION - export quaternions
%  BUNGE      - Bunge convention (default)
%  ABG        - Matthies convention (alpha beta gamma)
%  DEGREE     - output in degree (default)
%  RADIANS    - output in radians

G = [ebsd.orientations];
q = quaternion(G);

if ~check_option(varargin,'quaternion')
  [a,b,g] = quat2euler(q,'Bunge');
  d = [a(:),b(:),g(:)]; 

  if ~check_option(varargin,{'radians','radiant','radiand'})
    d = d ./ degree; 
  end
else
  d = [q(:).a,q(:).b,q(:).c,q(:).d]; 
end

if ~isempty(ebsd.xy), d = [d, cell2mat(ebsd.xy)]; end %#ok<NASGU>

save(fname,'d','-ASCII','-single');
