function ebsd = subSet(ebsd,ind,varargin)
% indexing of EBSD data
%
% Syntax
%   subSet(ebsd,ind)
%

ebsd = subSet@dynProp(ebsd,ind);
ebsd.pos = ebsd.pos(ind);
ebsd.rotations = ebsd.rotations(ind);
ebsd.phaseId = reshape(ebsd.phaseId(ind),[],1);
ebsd.id = ebsd.id(ind);
if ~isempty(ebsd.A_D), ebsd.A_D = ebsd.A_D(ind(:),ind(:)); end

if (isa(ebsd,'EBSDsquare') || isa(ebsd,'EBSDhex')) && ...
  ~check_option(varargin,'keepGrid') && ...  
  (islogical(ind) || min(size(ind))==1)
  ebsd = EBSD(ebsd);
end
