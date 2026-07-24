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
% Syntax
%   check_gridDistortionBenchmark
%
% See also
% EBSD/lattice EBSD/transform check_grainReconstructionBenchmark

ebsd = mtexdata('forsterite');

ij0 = ebsd.lattice.ij;
x = ebsd.pos.x; xCenter = (min(x) + max(x)) / 2;
y = ebsd.pos.y; yCenter = (min(y) + max(y)) / 2; yHalf = (max(y) - min(y)) / 2;

% trapFrac is the fractional x-scaling applied at the map's outermost rows
% (e.g. 0.02 stretches/compresses the top and bottom row by 2%); 0.49 is
% just under the 0.5-cell-drift point at which even a perfectly rigid
% reconstruction would become ambiguous.
trapFracs = [0.0005 0.001 0.005 0.01 0.02 0.05 0.10 0.20 0.30 0.49];

fprintf('%-10s %10s\n', 'trapFrac', 'ij exact');
fprintf('%s\n', repmat('-',1,22));

allOk = true;
for k = 1:numel(trapFracs)
  trapFrac = trapFracs(k);

  ebsdT = transform(ebsd, @(pos) vector3d( ...
    xCenter + (pos.x-xCenter) .* (1 + trapFrac*(pos.y-yCenter)/yHalf), ...
    pos.y, pos.z));

  ok = isequal(ebsdT.lattice.ij, ij0);
  allOk = allOk && ok;

  fprintf('%-10.4f %10s\n', trapFrac, mark(ok));
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
