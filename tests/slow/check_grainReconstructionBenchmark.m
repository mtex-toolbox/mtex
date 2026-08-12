function check_grainReconstructionBenchmark(varargin)
% regression + performance benchmark for EBSD.calcGrains
%
% Runs calcGrains on three reference datasets - a multi-phase rock
% (forsterite, square grid), a single-phase metal (copper, hexagonal
% grid), and a very large two-phase steel map (1C_1.ctf, not part of the
% repo, ~2.5M pixels) - and checks the reconstructed grain topology
% against a stored reference snapshot.
%
% Grain count and total boundary length are deterministic invariants of
% calcGrains for fixed input and options (exactly reproducible run to
% run, barring an actual algorithmic change), so any drift beyond a tiny
% floating point tolerance means the reconstruction itself changed -
% intentionally or not. Timings are only ever reported, never compared
% with a pass/fail - wall-clock varies with machine load - which is what
% makes this useful as a running scratchpad for tracking speedups /
% regressions while working on spatialDecomposition, jcvoronoi, etc.
%
% This is a manual/opt-in performance benchmark, not a routine correctness
% check: loading the full-size reference datasets (and, where present, the
% ~2.5M pixel steel1C_1 map) makes a single run take from several seconds
% to over a minute. Run it deliberately after a feature/optimization is
% finished, not as part of routine testing - see check_calcGrainsCases for
% the fast (<1s), small-map correctness suite that covers grid type and
% transform combinations.
%
% Syntax
%   check_grainReconstructionBenchmark
%   check_grainReconstructionBenchmark('update')
%
% Options
%  update - overwrite the stored reference with the current run's
%           numbers. Only do this after independently verifying the new
%           numbers are correct, not merely "the test now passes".
%
% The large steel dataset is not part of the repository (git-ignored, >
% 150MB) and is only expected on the machine(s) this benchmark was set
% up on. If $HOME/mtex/data/1C_1.ctf is missing, that case is skipped
% with a warning rather than failing.

doUpdate = check_option(varargin,'update');

refFile = fullfile(fileparts(mfilename('fullpath')), ...
  'benchmarkData','grainReconstructionReference.m');

if isfile(refFile)
  ref = grainReconstructionReference();
else
  ref = struct();
end

cases = benchmarkCases();
results = struct();
allOk = true;

fprintf('%-12s %8s %8s %14s %14s %14s %10s %10s\n', ...
  'dataset','#grains','#QPgrain','totalLen','totalLenQP','meanArea','time(s)','vs. ref');
fprintf('%s\n', repmat('-',1,101));

for k = 1:numel(cases)
  c = cases{k};

  if ~c.available
    fprintf('%-12s  SKIPPED (%s)\n', c.name, c.skipReason);
    continue
  end

  ebsd = c.load();
  ebsdI = ebsd('indexed');

  t = zeros(c.reps,1);
  for r = 1:c.reps
    t0 = tic;
    grains = calcGrains(ebsdI);
    t(r) = toc(t0);
  end
  grainsQP = calcGrains(ebsdI,'removeQuadruplePoints');

  m = struct();
  m.nGrains   = length(grains);
  m.nGrainsQP = length(grainsQP);
  m.totalLen  = sum(grains.boundary.segLength);
  m.meanArea  = mean(grains.area);
  % the QP variant's own geometry. Without it nGrainsQP is the only probe of
  % the removeQuadruplePoints path - a bare integer with nothing to say
  % whether a drift is a tie-break shuffling grains between counts or real
  % boundary being destroyed. That is exactly how G38 stayed invisible.
  m.totalLenQP = sum(grainsQP.boundary.segLength);
  m.time      = median(t);
  results.(c.name) = m;

  if isfield(ref,c.name) && ~doUpdate
    speedTxt = sprintf('%.2fx', ref.(c.name).time / m.time);
  else
    speedTxt = '(no ref)';
  end
  fprintf('%-12s %8d %8d %14.4f %14.4f %14.4f %10.4f %10s\n', ...
    c.name, m.nGrains, m.nGrainsQP, m.totalLen, m.totalLenQP, m.meanArea, ...
    m.time, speedTxt);

  % Reported, not asserted against totalLen. The segments removeQuadruplePoints
  % adds have zero length, so one might expect totalLenQP == totalLen - and on
  % forsterite and copper it holds exactly. It is not universal: merge drops
  % every segment whose two sides end up in the same grain (@grain2d/merge:204),
  % so where a quadruple point merge joins two grains that also touch along a
  % real boundary elsewhere, that boundary goes too. steel1C_1 loses 55.4 that
  % way, identically before and after the G38 fix. What catches a regression is
  % the comparison against the stored reference below.
  if ~doUpdate && isfield(ref,c.name)
    allOk = compareToReference(c.name, m, ref.(c.name)) && allOk;
  end
end

if doUpdate
  writeReferenceFile(refFile, results);
  fprintf('\nreference updated: %s\n', refFile);
  return
end

if ~allOk
  error('check_grainReconstructionBenchmark:accuracy', ...
    ['grain reconstruction result(s) differ from the stored reference ' ...
    '(see above) - if this is an intentional change, verify it ' ...
    'independently, then run check_grainReconstructionBenchmark(''update'')']);
end
fprintf('\ngrain reconstruction benchmark: all datasets match the reference\n');

end

% ===========================================================================
function writeReferenceFile(refFile, results)
% write the reference as a plain .m file (not .mat): *.mat is globally
% gitignored in this repo, and a text file gives a readable git diff
% whenever the reference legitimately changes.

% anything a human wrote into the old header is carried across before the
% file is overwritten. The numbers in this file are auto-generated but the
% commentary explaining WHY each of them is what it is - which measurement
% settled it, which commit moved it - is not reproducible, and an earlier
% version of this writer silently destroyed 25 lines of it on every update.
preserved = readProvenance(refFile);

fid = fopen(refFile,'w');
closeFid = onCleanup(@() fclose(fid));

fprintf(fid, 'function ref = grainReconstructionReference()\n');
fprintf(fid, '%% reference snapshot for check_grainReconstructionBenchmark\n');
fprintf(fid, '%%\n');
fprintf(fid, '%% Auto-generated by check_grainReconstructionBenchmark(''update'') - do\n');
fprintf(fid, '%% not hand-edit. Regenerate only after independently verifying the new\n');
fprintf(fid, '%% numbers are correct, not merely "the test now passes".\n');

for k = 1:numel(preserved)
  fprintf(fid, '%s\n', preserved{k});
end

fprintf(fid, '\n');
fprintf(fid, 'ref = struct();\n');

names = fieldnames(results);
for k = 1:numel(names)
  n = names{k};
  m = results.(n);
  fprintf(fid, '\n');
  fprintf(fid, 'ref.%s.nGrains    = %d;\n',    n, m.nGrains);
  fprintf(fid, 'ref.%s.nGrainsQP  = %d;\n',    n, m.nGrainsQP);
  fprintf(fid, 'ref.%s.totalLen   = %.10f;\n', n, m.totalLen);
  fprintf(fid, 'ref.%s.totalLenQP = %.10f;\n', n, m.totalLenQP);
  fprintf(fid, 'ref.%s.meanArea   = %.10f;\n', n, m.meanArea);
  fprintf(fid, 'ref.%s.time       = %.4f;\n',  n, m.time);
end

fprintf(fid, '\nend\n');

end

% ===========================================================================
function ok = compareToReference(name, m, r)

ok = true;
if m.nGrains ~= r.nGrains
  fprintf('  [%s] FAIL: #grains %d vs. reference %d\n', name, m.nGrains, r.nGrains);
  ok = false;
end
if m.nGrainsQP ~= r.nGrainsQP
  fprintf('  [%s] FAIL: #grains (removeQuadruplePoints) %d vs. reference %d\n', ...
    name, m.nGrainsQP, r.nGrainsQP);
  ok = false;
end
tol = 1e-8;
if abs(m.totalLen - r.totalLen) > tol * max(1,abs(r.totalLen))
  fprintf('  [%s] FAIL: total boundary length %.6f vs. reference %.6f\n', ...
    name, m.totalLen, r.totalLen);
  ok = false;
end
if abs(m.meanArea - r.meanArea) > tol * max(1,abs(r.meanArea))
  fprintf('  [%s] FAIL: mean grain area %.6f vs. reference %.6f\n', ...
    name, m.meanArea, r.meanArea);
  ok = false;
end
% only present in references written after the QP geometry was added
if isfield(r,'totalLenQP') && ...
    abs(m.totalLenQP - r.totalLenQP) > tol * max(1,abs(r.totalLenQP))
  fprintf('  [%s] FAIL: QP total boundary length %.6f vs. reference %.6f\n', ...
    name, m.totalLenQP, r.totalLenQP);
  ok = false;
end

end

% ===========================================================================
function cases = benchmarkCases()

cases = {};

cases{end+1} = struct('name','forsterite', 'reps',3, ...
  'available',true, 'skipReason','', ...
  'load', @() mtexdata('forsterite')); %#ok<*NBRAK2>

cases{end+1} = struct('name','copper', 'reps',3, ...
  'available',true, 'skipReason','', ...
  'load', @() mtexdata('copper'));

bigFile = fullfile(getenv('HOME'),'mtex','data','1C_1.ctf');
cases{end+1} = struct('name','steel1C_1', 'reps',1, ...
  'available', isfile(bigFile), ...
  'skipReason', [bigFile ' not found - large personal dataset, not part of the repo'], ...
  'load', @() EBSD.load(bigFile));

end

% ===========================================================================
function preserved = readProvenance(refFile)
% the hand written part of the old header, i.e. every comment line above
% "ref = struct()" that is not one of the generated boilerplate lines

preserved = {};
if ~isfile(refFile), return; end

txt = strsplit(fileread(refFile),newline);

% the generated lines, matched on their text so that reordering them here
% does not start duplicating them in the file
boiler = { ...
  '% reference snapshot for check_grainReconstructionBenchmark', ...
  '%', ...
  '% Auto-generated by check_grainReconstructionBenchmark(''update'') - do', ...
  '% not hand-edit. Regenerate only after independently verifying the new', ...
  '% numbers are correct, not merely "the test now passes".'};

for k = 2:numel(txt)          % skip the function line

  line = strtrim(txt{k});

  if startsWith(line,'ref = struct'), break; end
  if isempty(line), continue; end
  if ~startsWith(line,'%'), continue; end
  if any(strcmp(line,boiler)), continue; end

  if isempty(preserved), preserved{end+1} = ''; end %#ok<AGROW>
  preserved{end+1} = txt{k}; %#ok<AGROW>

end

end
