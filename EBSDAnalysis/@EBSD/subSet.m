function ebsd = subSet(ebsd,ind)
% indexing of EBSD data
%
% Syntax
%   subSet(ebsd,ind)
%

ebsd = subSet@dynProp(ebsd,ind);
ebsd.rotations = ebsd.rotations(ind);
ebsd.phaseId = reshape(ebsd.phaseId(ind),[],1);
ebsd.id = ebsd.id(ind);
%if ~isempty(ebsd.grainId), ebsd.grainId = ebsd.grainId(ind); end
if ~isempty(ebsd.A_D), ebsd.A_D = ebsd.A_D(ind(:),ind(:)); end

if (islogical(ind) || min(size(ind))==1) && (isa(ebsd,'EBSDsquare') || isa(ebsd,'EBSDhex'))
  ebsd = EBSD(ebsd);
end
