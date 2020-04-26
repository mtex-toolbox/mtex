function varargout = calcTensor(ebsd,varargin)
% compute the average tensor for an EBSD data set
%
% Syntax
%   % applies a tensor on a given phase
%   [TVoigt, TReuss, THill] = calcTensor(ebsd('phase2'),T_phase2)
%
%   % applies each tensor given in order of input to each phase
%   [TVoigt, TReuss, THill] = calcTensor(ebsd,T_phase1,T_phase2,...) 
%
%   % returns the specified  tensor
%   THill = calcTensor(ebsd,T_phase1,T_phase2,'Hill') 
%
%   % geometric mean instead of arithmetric one
%   TGeom = calcTensor(ebsd,T_phase1,T_phase2,'geometric') 
%
% Input
%  ebsd     - @EBSD
%  T_phaseN - @tensor for the N-th phase
%
% Output
%  T    - @tensor
%
% Options
%  Voigt     - Voigt mean
%  Reuss     - Reuss mean
%  Hill      - Hill mean
%  geometric - geometric mean
%
% See also
% tensor/mean

% consider only indexed pixels
ebsd = ebsd.subSet(ebsd.isIndexed);

% cycle through indexed phases
for p = ebsd.indexedPhasesId
  
  % search for a fiting tensor
  Tind = cellfun(@(t) isa(t,'tensor') && eq(t.CS,ebsd.CSList{p},'Laue'),varargin);
  if any(Tind)
    T = varargin{find(Tind,1)};
  else
    error('\nMissing tensor for phase: %s\n',ebsd.CSList{p}.mineral);
  end
  
  % rotate tensors
  TRot(ebsd.phaseId == p) = ...
    orientation(ebsd.rotations(ebsd.phaseId == p),ebsd.CSList{p}) * T;
 
end
 
% compute the averages
[varargout{1:nargout}] = mean(TRot,varargin{:});
 
end

function out = isappr(CS1,CS2)
% check for correct symmetry

out = (CS1.id == CS2.id) && max(abs(norm(CS1.axes)-norm(CS2.axes))./norm(CS1.axes))<0.1;

end
