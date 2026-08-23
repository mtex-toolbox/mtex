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
% truth exactly, up to the distortion strength recorded below.
%
% Run for TWO distortion families, because they stress different halves of
% the model. The trapezoid moves each row along itself and leaves the rows
% where they were, so the inner cell size stays exactly nominal and only
% varies from row to row. The tilt is the homography through the same four
% corners - the same outline - but a genuine perspective, so it foreshortens
% across the rows as well and the inner cell size varies along the scan
% itself. A model that is a function of the row alone cannot see that, and a
% phase subset's multi-cell gaps are long enough for it to round to the wrong
% cell: on a tilted map the column index drifted by tens of cells while the
% row index stayed exact, and no two pixels collided, so nothing noticed.
%
% Run in BOTH scan orders. assignGridIndex walks the list, so the same
% measurements handed over in the other raster order are a genuinely
% different problem for it: file order (x fastest, as a .ctf is written)
% puts the distorted direction along the inner, densely sampled direction,
% while grid order (y fastest, what gridify produces and therefore what
% EBSD.load now returns) makes it the outer one, which is reconstructed from
% a drift model rather than measured cell by cell. Grid order is thus the
% weaker of the two by construction - but it is also the one users now get,
% so it is pinned here rather than left untested. Both orders were exact
% only to 0.0005 resp. the full range before the drift model was added to
% the outer step.
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
% assignGridIndex.m than the full map alone can (see there). The sparser
% the phase the earlier it gives out, per the limitation documented there.
%
% This checks ONLY ebsd.lattice.ij recovery, not grain reconstruction -
% correct ij recovery is necessary for correct grain reconstruction but not
% sufficient on its own; see check_calcGrainsCases for the
% grain-reconstruction-level regression test (spatialDecompositionGrid's
% cells2posId helper).
%
% Syntax
%   check_gridDistortionBenchmark
%
% See also
% EBSD/lattice EBSD/transform check_grainReconstructionBenchmark check_calcGrainsCases

% trapFrac is the fractional x-scaling applied at the map's outermost rows
% (e.g. 0.02 stretches/compresses the top and bottom row by 2%); 0.49 is
% just under the 0.5-cell-drift point at which even a perfectly rigid
% reconstruction would become ambiguous. A realistic stage drift is at the
% bottom end of this range, so even the weakest entry below has a wide
% margin over anything a real scan produces.
trapFracs = [0.0005 0.001 0.005 0.01 0.02 0.05 0.10 0.20 0.30 0.49];

selections = {'full','Forsterite','Enstatite','Diopside'};

% highest trapFrac at which ij is still recovered exactly; the test fails if
% any entry gets worse. Trapezoid measured 2026-08-13, tilt 2026-08-23.
expected.trapezoid = [0.10 0.05 0.02 0.02;    % grid order, y fastest
                      0.49 0.20 0.20 0.20];   % file order, x fastest
expected.tilt      = [0.05 0.05 0.02 0.02;
                      0.10 0.10 0.20 0.10];

ebsdGrid = mtexdata('forsterite');

% the same measurements in file order: oldId is what gridify recorded when
% it reordered them, so sorting by it undoes exactly that reordering
ebsdList = EBSD(ebsdGrid);
[~,fileOrder] = sort(ebsdList.oldId(:));
ebsdList = ebsdList(fileOrder);

orders = {'grid order (y fastest)', ebsdGrid; 'file order (x fastest)', ebsdList};

allOk = true;

for o = 1:size(orders,1)

  ebsd = orders{o,2};

  % (:) is load bearing: forsterite imports as an @EBSDsquare, so pos.x is
  % the (r x c) matrix of the map and min/max would reduce it per column
  x = ebsd.pos.x(:); xCenter = (min(x) + max(x)) / 2;
  y = ebsd.pos.y(:); yCenter = (min(y) + max(y)) / 2; yHalf = (max(y) - min(y)) / 2;
  distort = @(trapFrac) @(pos) vector3d( ...
    xCenter + (pos.x-xCenter) .* (1 + trapFrac*(pos.y-yCenter)/yHalf), ...
    pos.y, pos.z);

  % the same outline as the trapezoid - the homography through its four
  % corners - but a genuine perspective, so it foreshortens ACROSS the rows as
  % well. That is the part a per-row model cannot see: the trapezoid leaves
  % the inner cell size exactly nominal everywhere, a tilt varies it along the
  % scan itself. See assignGridIndex/fitCellSize.
  corners = vector3d([min(x) max(x) max(x) min(x)].', ...
    [min(y) min(y) max(y) max(y)].', 0);
  tilt = @(trapFrac) fitTilt(corners, distort(trapFrac));

  families = {'trapezoid', distort; 'tilt', tilt};

  for f = 1:size(families,1)

    famName = families{f,1};
    famFun  = families{f,2};
    famExp  = expected.(famName);

    fprintf('\n=== %s, %s ===\n', orders{o,1}, famName);
    fprintf('%-12s %10s %10s %8s\n', 'selection', 'exact to', 'expected', 'pixels');
    fprintf('%s\n', repmat('-',1,44));

    for s = 1:numel(selections)

      if strcmp(selections{s},'full')
        ebsdSel = ebsd;
      else
        ebsdSel = ebsd(selections{s});
      end

      ij0 = ebsdSel.lattice.ij;

      achieved = 0;
      for k = 1:numel(trapFracs)
        if ~isequal(transform(ebsdSel,famFun(trapFracs(k))).lattice.ij, ij0)
          break
        end
        achieved = trapFracs(k);
      end

      ok = achieved >= famExp(o,s);
      allOk = allOk && ok;

      fprintf('%-12s %10g %10g %8d %s\n', selections{s}, achieved, ...
        famExp(o,s), length(ebsdSel), mark(ok));

    end
  end
end

if ~allOk
  error(['assignGridIndex recovers the true grid index over a smaller '...
    'range of distortion than it used to - see the table above']);
end

fprintf('\ngrid distortion benchmark: ij recovered exactly over the expected range\n');

end

% =========================================================================
function s = mark(ok)
if ok, s = ''; else, s = '  <- WORSE'; end
end

% =========================================================================
function T = fitTilt(corners, fun)
% the homography taking the map's four corners where fun takes them
%
% Four correspondences determine a homography exactly, so there is nothing
% for the robust reweighting to outvote and it would only report the
% resulting rank deficiency.

T = spatialTransformProjective.fit(corners, fun(corners), 'noRobust');

end
