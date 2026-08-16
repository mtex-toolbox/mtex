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
    error('%s',missingTensorMessage(ebsd.CSList(p),varargin));
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

% the averages live in the frame of the map - stamp the outputs (the old
% code stamped the local TRot after the outputs were already extracted,
% so they never carried the convention)
for k = 1:nargout, varargout{k}.frame = ebsd.pos.frame; end

% average density - only over the indexed pixels, as the density of the not
% indexed ones is unknown (they keep the NaN they were initialised with) and
% would otherwise render the average, and with it all derived quantities
% like wave velocities, NaN
if hasDensity
  for k=1:nargout, varargout{k}.opt.density = mean(density(ebsd.isIndexed)); end
end

end

% -------------------------------------------------------------------------

function msg = missingTensorMessage(cs,args)
% explain *why* no tensor matched - a near miss on the lattice parameters is
% by far the most common cause and is easily mistaken for a missing tensor

msg = sprintf('\nMissing tensor for phase: %s\n',cs.mineral);

% look for a tensor that agrees on mineral name and Laue group, i.e. one
% that sim rejected only because of the lattice parameters
for k = 1:numel(args)

  T = args{k};
  if ~isa(T,'tensor') || ~isa(T.CS,'crystalSymmetry'), continue; end
  if ~strcmpi(T.CS.mineral,cs.mineral) || T.CS.Laue.id ~= cs.Laue.id, continue; end

  dAxes = max(abs(T.CS.abc - cs.abc) / max(T.CS.abc));
  dAng  = max(abs(T.CS.abg - cs.abg));

  msg = [msg sprintf([ ...
    '\nA tensor for this mineral and Laue group was given, but its crystal\n' ...
    'reference frame deviates too much to be matched automatically:\n' ...
    '  tensor   axes %s  angles %s\n' ...
    '  phase    axes %s  angles %s\n' ...
    '  relative deviation %.1f%% in the axes, %.4f rad in the angles,\n' ...
    '  while at most 1%% and 0.01 rad are accepted.\n\n' ...
    'Transform the tensor into the reference frame of the measured phase first:\n' ...
    '  T = transformReferenceFrame(T,ebsd(''%s'').CS)\n'], ...
    num2str(T.CS.abc,'%.4g '), num2str(T.CS.abg./degree,'%.4g '), ...
    num2str(cs.abc,'%.4g '), num2str(cs.abg./degree,'%.4g '), ...
    100*dAxes, dAng, cs.mineral)]; %#ok<AGROW>

  return
end

end

