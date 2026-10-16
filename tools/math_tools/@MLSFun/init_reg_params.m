function F = init_reg_params(F,varargin)
% calibrate the goal-oriented regularization parameters
%
% Syntax
%   F = init_reg_params(F)         % set the parameters not set yet
%   F = init_reg_params(F,'force') % overwrite those set explicitly too
%
% Input
%  F - @S2FunMLS, @SO3FunMLS
%
% Output
%  F - @S2FunMLS, @SO3FunMLS with mincond, maxcond and targetcond set
%
% Flags
%  force - overwrite parameters the user has set explicitly (also 'overwrite')
%
% Description
% The thresholds are placed relative to the baseline amplification chi0 of
% the ansatz space. chi0 depends only on the degree, the weight function and
% the domain, not on the nodes, so it is measured on a small
% well-distributed reference grid, and one multiple of chi0 serves on S2 and
% on SO(3) at every degree.

if F.degree == 0
  F.regularize = false;
  return
end

if F.use_smooth_delta && F.delta == 0 && isempty(F.auxgrid)
  F = F.init_auxgrid;
end

% assigning mincond also assigns targetcond, so record the choices first
force = check_option(varargin,{'force','overwrite'});
setMincond = isempty(F.mincond) || force;
setMaxcond = isempty(F.maxcond) || force;
setTargetcond = isempty(F.targetcond) || force;
targetcond = F.targetcond;

% onset at 10 chi0, full correction two decades later, target at the onset
chi0 = F.baseline_amplification;
if setMincond, F.mincond = 10 * chi0; end
if setMaxcond, F.maxcond = 100 * (10 * chi0); end
if setTargetcond
  F.targetcond = 10 * chi0;
else
  F.targetcond = targetcond;
end

% explicit values are checked, never adjusted
if F.mincond < 1
  error('mincond must be at least 1.');
end
if F.targetcond < 1 || F.targetcond > F.mincond
  error('targetcond must satisfy 1 <= targetcond <= mincond.');
end
if F.maxcond <= F.mincond
  error('maxcond must be strictly larger than mincond.');
end

F.regularize = true;

end
