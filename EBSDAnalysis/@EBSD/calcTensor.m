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
%   % geometric mean instead of arithmetic one
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

% maybe we need to average the density as well - only meaningful if every
% indexed phase contributes one, as a missing density stays NaN and would
% render the average NaN
density = nan(size(ebsd));
hasDensity = ~isempty(ebsd.indexedPhasesId);

% cycle through indexed phases
for p = ebsd.indexedPhasesId
  
  % search for a fitting tensor
  Tind = find(cellfun(@(t) isa(t,'tensor') && sim(t.CS,ebsd.CSList(p)),varargin),1);
  if any(Tind)
    T = varargin{Tind};
  else
    error('\nMissing tensor for phase: %s\n',ebsd.CSList(p).mineral);
  end
  
  % extract density
  if isfield(T.opt,'density')
    density(ebsd.phaseId == p) = T.opt.density;
  else
    hasDensity = false;
  end

  % rotate tensors
  TRot(ebsd.phaseId == p) = ...
    orientation(ebsd.rotations(ebsd.phaseId == p),ebsd.CSList(p)) * T; %#ok<AGROW>
 
end

% compute the averages
TRot = TRot(ebsd.isIndexed);
[varargout{1:nargout}] = mean(TRot,varargin{:});

TRot.how2plot = ebsd.how2plot;

% average density - only over the indexed pixels, as the density of the not
% indexed ones is unknown (they keep the NaN they were initialised with) and
% would otherwise render the average, and with it all derived quantities
% like wave velocities, NaN
if hasDensity
  for k=1:nargout, varargout{k}.opt.density = mean(density(ebsd.isIndexed)); end
end

end

