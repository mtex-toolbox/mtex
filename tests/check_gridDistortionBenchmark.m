function check_gridDistortionBenchmark(varargin)
% regression test for EBSD/lattice robustness to smooth grid distortion
%
% Simulates a common EBSD stage-drift artefact - each scan row scaled about
% the map centre by an amount that grows linearly with row index (a
% trapezoidal distortion) - applied to the real Forsterite reference map
% (see check_grainReconstructionBenchmark) rather than a small synthetic
% grid, since the failure mode this guards against (a smooth distortion
% overwhelming the rounding tolerance at the line-to-line scan jump) only
% shows up once the map is realistically wide - a tiny synthetic grid
% stays safe at distortion levels where a real map already fails.
%
% ebsd.lattice.ij on the undistorted map is exact ground truth (Forsterite
% is a complete, gap-free rectangle). After distorting only the
% x-position per row, the recomputed ij must recover that same ground
% truth exactly, at every tested distortion strength up to the point
% where the distortion itself becomes fundamentally ambiguous (half a
% cell of drift at the map edge).
%
% The row a pixel belongs to is identified by its physical y position,
% not by a column of ebsd.lattice.ij: which of the two ij columns happens
% to correlate with y (row) vs x (column) depends on the lattice basis'
% internal choice of which of its two directions comes first, which is
% not fixed - so indexing ij directly here would silently distort along
% the wrong axis on a run where that choice comes out the other way.
%
% Also checked on a phase subset (ebsd('Forsterite') etc.), not just the
% full map: selecting one phase out of several leaves gaps within a scan
% line, not only between lines, which stresses a different part of
% assignGridIndex.m than the full map alone can (see there) - and is
% checked only up to a realistic distortion level, not the full range
% above, per the limitation documented in assignGridIndex.m.
%
% This checks ONLY ebsd.lattice.ij recovery, not grain reconstruction -
% correct ij recovery is necessary for correct grain reconstruction but not
% sufficient on its own; see check_calcGrainsTransform for the
% grain-reconstruction-level regression test (spatialDecompositionGrid's
% cells2posId helper).
%
% Syntax
%   check_gridDistortionBenchmark
%
% See also
% EBSD/lattice EBSD/transform check_grainReconstructionBenchmark

ebsd = mtexdata('forsterite');

x = ebsd.pos.x; xCenter = (min(x) + max(x)) / 2;
y = ebsd.pos.y; yCenter = (min(y) + max(y)) / 2; yHalf = (max(y) - min(y)) / 2;
distort = @(trapFrac) @(pos) vector3d( ...
  xCenter + (pos.x-xCenter) .* (1 + trapFrac*(pos.y-yCenter)/yHalf), ...
  pos.y, pos.z);

allOk = true;

% --- full map: a complete, gap-free rectangle -----------------------
fprintf('--- full map ---\n');
fprintf('%-10s %10s\n', 'trapFrac', 'ij exact');
fprintf('%s\n', repmat('-',1,22));

ij0 = ebsd.lattice.ij;

% trapFrac is the fractional x-scaling applied at the map's outermost rows
% (e.g. 0.02 stretches/compresses the top and bottom row by 2%); 0.49 is
% just under the 0.5-cell-drift point at which even a perfectly rigid
% reconstruction would become ambiguous.
trapFracs = [0.0005 0.001 0.005 0.01 0.02 0.05 0.10 0.20 0.30 0.49];

for k = 1:numel(trapFracs)
  ebsdT = transform(ebsd, distort(trapFracs(k)));
  ok = isequal(ebsdT.lattice.ij, ij0);
  allOk = allOk && ok;
  fprintf('%-10.4f %10s\n', trapFracs(k), mark(ok));
end

% --- phase subsets: gaps within a line too, not just between lines ---
subsetTrapFracs = [0.0005 0.001 0.005 0.01 0.02 0.05 0.10 0.20];
for phase = {'Forsterite','Enstatite','Diopside'}

  fprintf('\n--- %s subset ---\n', phase{1});
  fprintf('%-10s %10s\n', 'trapFrac', 'ij exact');
  fprintf('%s\n', repmat('-',1,22));

  ebsdPh = ebsd(phase{1});
  ijPh0 = ebsdPh.lattice.ij;

  for k = 1:numel(subsetTrapFracs)
    ebsdPhT = transform(ebsdPh, distort(subsetTrapFracs(k)));
    ok = isequal(ebsdPhT.lattice.ij, ijPh0);
    allOk = allOk && ok;
    fprintf('%-10.4f %10s\n', subsetTrapFracs(k), mark(ok));
  end
end

if ~allOk
  error(['assignGridIndex failed to recover the true grid index under ' ...
    'trapezoidal distortion at one or more of the tested levels - see above']);
end

fprintf('\ngrid distortion benchmark: ij recovered exactly at all tested distortion levels\n');

end

% =========================================================================
function s = mark(ok)
if ok, s = 'yes'; else, s = 'FAIL'; end
end
