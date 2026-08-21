function S2F = init_reg_params(S2F, varargin)
% initialize the conservative goal-oriented parameters on a random grid
%
% Syntax
%   S2F = init_reg_params(S2F)
%   S2F = init_reg_params(S2F,'force')
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

if S2F.degree == 0
  S2F.regularize = false;
  return;
end

if S2F.use_smooth_delta && (S2F.delta == 0) && isempty(S2F.auxgrid)
  S2F = S2F.init_auxgrid;
end
% Assigning mincond also updates targetcond for backward compatibility. Record
% the user choices before changing any of the three parameters.
force = check_option(varargin, {'force', 'overwrite'});
setMincond = isempty(S2F.mincond) || force;
setMaxcond = isempty(S2F.maxcond) || force;
setTargetcond = isempty(S2F.targetcond) || force;
manualTargetcond = S2F.targetcond;

% onset relative to the healthy baseline, the transition keeps the former width
onsetFactor = 10;
fullFactor = 100;

chi0 = S2F.baseline_amplification;

mincond_auto = onsetFactor * chi0;
maxcond_auto = fullFactor * mincond_auto;
targetcond_auto = mincond_auto;

if setMincond, S2F.mincond = mincond_auto; end
if setMaxcond, S2F.maxcond = maxcond_auto; end
if setTargetcond
  S2F.targetcond = targetcond_auto;
else
  % Assigning mincond also assigns targetcond; restore an explicit target.
  S2F.targetcond = manualTargetcond;
end

% Respect manual values. In particular, do not silently enlarge the transition
% interval or replace the limiting target one by 1.1.
if S2F.mincond < 1
  error('mincond must be at least 1.');
end
if S2F.targetcond < 1 || S2F.targetcond > S2F.mincond
  error('targetcond must satisfy 1 <= targetcond <= mincond.');
end
if S2F.maxcond <= S2F.mincond
  error('maxcond must be strictly larger than mincond.');
end

S2F.regularize = true;

end
