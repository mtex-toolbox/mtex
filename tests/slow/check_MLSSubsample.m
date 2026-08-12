function check_MLSSubsample
% check that the 'subsample' option of the MLS approximation still runs
%
% The optimal subset selection asks linprog for the Lagrange multipliers,
% which the simplex algorithms do not always return: on R2024b and R2025a
% every simplex variant fails with "Unrecognized field name optimstatus", or
% an internal error for dual-simplex-legacy. That was gated on the MATLAB
% version being at least 25, which got the affected range wrong - the
% failure is already there on R2024b, so 'subsample' died on the release
% MTEX is developed against.
%
% The gate is now a capability probe: run one trivial program and fall back
% to interior-point-legacy only if it fails. Whatever a given release does,
% the multipliers come back.
%
% Only the S2 side is exercised here. SO3FunMLS carries the same private
% helper, but SO3FunMLS.m:319 calls syms, so it needs the Symbolic Math
% Toolbox and cannot run on a machine without it.

if isempty(ver('optim'))
  disp('check_MLSSubsample: skipped, no Optimization Toolbox');
  return
end

rng(0)
v = vector3d.rand(300);
f = cos(v.theta);

S2F = S2FunMLS(v,f,'subsample');

% the approximation has to be usable, not merely constructible
w = vector3d.rand(50);
err = max(abs(S2F.eval(w) - cos(w.theta)));

assert(err < 0.1, ...
  'check_MLSSubsample: the subsampled approximation is off by %g', err)

disp('check_MLSSubsample: passed');

end
