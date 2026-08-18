function SO3F = init_reg_params(SO3F, varargin)
% initialize the conservative goal-oriented parameters on a random grid
%
% Syntax
%   SO3F = init_reg_params(SO3F)
%   SO3F = init_reg_params(SO3F,'force')
%
% The thresholds are placed relative to the healthy baseline amplification
% chi0 of the ansatz space. chi0 depends only on the degree, the weight
% function and the dimension of the manifold, not on the nodes, so it is
% measured on a small well-distributed reference grid. Placing mincond at a
% fixed multiple of chi0 makes one constant valid on S2 and on SO(3) and at
% every degree, which a fixed absolute threshold is not.
%
% Flags
%  force - overwrite parameters the user has set explicitly
%

if SO3F.degree == 0
  SO3F.regularize = false;
  return;
end

if SO3F.use_smooth_delta && (SO3F.delta == 0) && isempty(SO3F.auxgrid)
  SO3F = SO3F.init_auxgrid;
end
% Assigning mincond also updates targetcond for backward compatibility. Record
% the user choices before changing any of the three parameters.
force = check_option(varargin, {'force', 'overwrite'});
setMincond = isempty(SO3F.mincond) || force;
setMaxcond = isempty(SO3F.maxcond) || force;
setTargetcond = isempty(SO3F.targetcond) || force;
manualTargetcond = SO3F.targetcond;

% Onset relative to the healthy baseline. Ten is safe on well-distributed
% nodes at every degree tested and does not weaken the correction on badly
% distributed ones. The transition interval keeps the former width.
onsetFactor = 10;
fullFactor = 100;

chi0 = SO3F.baseline_amplification;

mincond_auto = onsetFactor * chi0;
maxcond_auto = fullFactor * mincond_auto;
targetcond_auto = mincond_auto;

if setMincond, SO3F.mincond = mincond_auto; end
if setMaxcond, SO3F.maxcond = maxcond_auto; end
if setTargetcond
  SO3F.targetcond = targetcond_auto;
else
  % Assigning mincond also assigns targetcond; restore an explicit target.
  SO3F.targetcond = manualTargetcond;
end

% Respect manual values. In particular, do not silently enlarge the transition
% interval or replace the limiting target one by 1.1.
if SO3F.mincond < 1
  error('mincond must be at least 1.');
end
if SO3F.targetcond < 1 || SO3F.targetcond > SO3F.mincond
  error('targetcond must satisfy 1 <= targetcond <= mincond.');
end
if SO3F.maxcond <= SO3F.mincond
  error('maxcond must be strictly larger than mincond.');
end

SO3F.regularize = true;

end
