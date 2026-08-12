function check_mexFunctions
% the compiled binaries must compute the right answer, not merely load
%
% This is a thin wrapper. The per-binary checks themselves live in check_mex,
% next to the download and install logic, so that there is exactly one place
% to add one - check_mex builds its check map from its own local functions,
% so a new check_<mexFile> there is picked up automatically, by the installer
% and by this suite at the same time.
%
% What this file adds is the verdict. check_mex is an installer: it prints
% its results and returns normally, so `matlab -batch "check_mex"` exits 0
% whether every binary works or none does - and startup_mtex runs it on every
% start. check_mex('strict') raises instead, and that is what makes the mex
% layer something the suite can gate on.
%
% An earlier version of this file re-implemented five of check_mex's checks
% rather than calling them. That has been folded back the other way: the
% stronger versions now live in check_mex, replacing what were bare
% "out = 1" stubs for EulerCyclesC, S1Grid_find_region, S2Grid_find and
% S2Grid_find_region, and strengthening insidepoly and S1Grid_find.
%
% See also
% check_mex check_mexComplete check_chainOrder check_jcvoronoi

% Missing binaries are check_mexComplete's business, and letting check_mex
% discover them would send it to the network to download them - which a test
% must not do. So the presence check comes first and this file skips rather
% than reaching for GitHub.
missing = check_mexComplete('quiet');

if ~isempty(missing)
  fprintf(['check_mexFunctions: %d mex binaries are missing for %s, ' ...
    'skipping.\n  %s\n  Run mex_install.\n'], ...
    numel(missing), mexext, strjoin(missing,', '));
  return
end

% the output is the installer's console report, which is of no interest when
% everything passes - on failure the error carries the names
evalc('check_mex(''strict'')');

disp('check_mexFunctions: passed');

end
