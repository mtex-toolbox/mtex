function varargout = runTests(varargin)
% run one tier of the MTEX test suite
%
% Syntax
%
%   runTests               % the core tier - the fast pre-commit suite
%   runTests core
%   runTests slow
%   runTests plotting
%   runTests all
%
%   report = runTests(...) % return the results instead of raising
%
% Input
%  tier - 'core' (default), 'slow', 'plotting' or 'all'
%
% Output
%  report - table with one row per test: name, tier, passed, seconds, error
%
% Description
%
% Each tier is a folder next to this file, and every check_*.m in it is a
% test of that tier - there is no list to register with, putting the file in
% the folder is what adds it. tests/lib holds fixtures rather than tests and
% is never collected.
%
% Which tier a test belongs in, and when to run each, is written down in
% tests/CLAUDE.md. The short version: core is the fast suite meant to be run
% before every commit and is held to a budget of 60 seconds; slow is real
% data and benchmarks; plotting is the tests whose assertion is about a
% graphics object.
%
% Every test runs in its own try/catch, so one failure does not hide the
% ones after it. Figures are invisible for the whole run, and figures, the
% random seed, the warning state and the reference frame register are reset
% between tests, so that a test cannot be made to pass or fail by the one
% that ran before it. This is why
% a test does not need the DefaultFigureVisible prologue that several of
% them used to carry individually.
%
% With no output argument the run raises an error if anything failed, so
% that
%
%   matlab -batch "runTests"
%
% exits nonzero and can gate a commit. Ask for the report output to inspect
% the failures programmatically instead.
%
% See also
% check_mtex check_mex check_mexComplete

tiers = {'core','slow','plotting'};

% ------------------------------------------------------------------ tier
tier = 'core';
if ~isempty(varargin) && (ischar(varargin{1}) || isstring(varargin{1}))
  tier = char(varargin{1});
end

if strcmpi(tier,'all')
  runList = tiers;
elseif any(strcmpi(tier,tiers))
  runList = tiers(strcmpi(tier,tiers));
else
  error('runTests:unknownTier', ...
    'unknown tier ''%s'' - expected one of ''%s'' or ''all''', ...
    tier, strjoin(tiers,''', '''));
end

% --------------------------------------------------------------- collect
% only check_*.m counts, so that a helper dropped into a tier folder is not
% mistaken for a test
root = fileparts(mfilename('fullpath'));

names = {}; tierOf = {};
for k = 1:numel(runList)

  folder = fullfile(root,runList{k});
  if ~isfolder(folder)
    error('runTests:missingTier','the tier folder %s does not exist',folder);
  end

  files = dir(fullfile(folder,'check_*.m'));
  [~,ord] = sort({files.name});                 % dir order is not guaranteed

  for f = ord
    [~,n] = fileparts(files(f).name);
    names{end+1} = n; %#ok<AGROW>
    tierOf{end+1} = runList{k}; %#ok<AGROW>
  end

  % a tier folder must contain nothing BUT tests. Without this an .m file
  % whose name does not start with check_ sits in the folder looking like a
  % test and is silently never run - which is exactly what checkMeanTensor
  % did, since it matches check* but not check_*.
  all = dir(fullfile(folder,'*.m'));
  stray = setdiff({all.name},{files.name});
  if ~isempty(stray)
    error('runTests:strayFile', ...
      ['%s contains %s, which does not match check_*.m and would never ' ...
       'be run. Rename it to check_<thing>.m, or move it to tests/lib if ' ...
       'it is a fixture rather than a test.'], ...
      runList{k}, strjoin(stray,', '));
  end
end

if isempty(names)
  error('runTests:noTests','no check_*.m found in %s',strjoin(runList,', '));
end

% ------------------------------------------------------------------- run
% invisible figures for the whole run - restored even if a test throws
% something the per-test catch does not see
oldVis = get(0,'DefaultFigureVisible');
resetAfterwards = onCleanup(@() set(0,'DefaultFigureVisible',oldVis)); %#ok<NASGU>
set(0,'DefaultFigureVisible','off');

passed  = false(1,numel(names));
seconds = zeros(1,numel(names));
errors  = cell(1,numel(names));

fprintf('\nrunTests: %s, %d tests\n\n',strjoin(runList,' + '),numel(names));

for k = 1:numel(names)

  resetSharedState;

  t = tic;
  try
    evalc(names{k});
    passed(k) = true;
  catch err
    errors{k} = err;
  end
  seconds(k) = toc(t);

  if passed(k)
    fprintf('  ok    %-46s %6.2f s\n',names{k},seconds(k));
  else
    fprintf(2,'  FAIL  %-46s %6.2f s\n',names{k},seconds(k));
  end
end

resetSharedState;

% --------------------------------------------------------------- summary
nFail = sum(~passed);

fprintf('\n  %d of %d passed in %.1f s\n',sum(passed),numel(names),sum(seconds));

% the slowest few, because core has a budget and it is only kept if the
% cost of keeping it is visible
[~,slowest] = sort(seconds,'descend');
slowest = slowest(1:min(5,numel(slowest)));
fprintf('  slowest: %s\n', strjoin(arrayfun(@(k) ...
  sprintf('%s %.1fs',names{k},seconds(k)),slowest,'UniformOutput',false),', '));

if nFail > 0
  fprintf(2,'\n  failures:\n');
  for k = find(~passed)
    fprintf(2,'    %s\n      %s\n',names{k},strtrim(errors{k}.message));
  end
end
fprintf('\n');

% ---------------------------------------------------------------- report
if nargout > 0

  varargout{1} = table(names(:),tierOf(:),passed(:),seconds(:),errors(:), ...
    'VariableNames',{'name','tier','passed','seconds','error'});

elseif nFail > 0

  error('runTests:failed','%d of %d tests failed: %s', ...
    nFail,numel(names),strjoin(names(~passed),', '));

end

end

% =========================================================================
function resetSharedState
% put back what a test may have disturbed, so that a test cannot be made to
% pass or fail by the one that ran before it. The warning state is included
% because a test that switches a warning off without an onCleanup - which
% has happened - otherwise leaks it into everything after it.
%
% The reference frame register is reset for the same reason, and the leak
% there is by design rather than by accident: importing EBSD data applies
% the file's plotting convention to the session default (ADR 0003), so
% every test that calls mtexdata legitimately moves it. That is what made
% check_plottingConventionOwnership fail in the tier while passing alone -
% check_gradient ran before it and left the default at 'y up'. This is the
% use referenceFrame.reset was written for.

close('all','force');
rng('default');
warning('on','all');
referenceFrame.reset;

end
