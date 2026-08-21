function check_arrowPlot
% check the 'arrow' option of vector3d/scatter, e.g. plotIPDF(...,'arrow')
%
% arrow measures its head in PIXELS and takes no notice of how long the
% segment is. Chaining arrows through a series of nearby orientations -
% which is what they are for - gives segments only a few pixels long, where
% the default 16 pixel head is longer than the whole arrow and sticks out
% well past its tip (#2072). Measured on the pair from that report, whose
% two points are 0.0096 apart in the plot: the patch spanned 0.0279, nearly
% three times the arrow. Zooming in was the known workaround, and it is
% exactly this ratio changing.
%
% The assertion is that the drawn patch does not extend beyond the segment
% it represents, which is what "overshoot" means, while a segment long
% enough to carry a full head is left exactly as it was.
%
% See also
% vector3d/scatter plotIPDF

oldVis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanUp = onCleanup(@() cleanup(oldVis)); %#ok<NASGU>

cs = crystalSymmetry('432','mineral','Austenite');

% the two nearly identical orientations of #2072
near = orientation.byEuler([70.6491 41.3549 5.15433; ...
  71.1963 40.9086 4.51548]*degree,cs);
far = orientation.byEuler([0 0 0; 30 40 20]*degree,cs);

% 'length',0 draws the bare shaft, so its extent is the segment
for pair = {near, far}

  segment = arrowExtent(pair{1},'length',0);
  extent = arrowExtent(pair{1});

  if extent > segment * 1.05
    error(['check_arrowPlot: an arrow over a %.4f long segment draws a '...
      '%.4f wide patch - the head overshoots its tip'], segment, extent);
  end
end

% the two pairs really are the two regimes: below and above the 16 pixel
% head the cap is protecting against
short = arrowExtent(near,'length',0);
long = arrowExtent(far,'length',0);
if ~(short < 0.02 && long > 0.1)
  error('check_arrowPlot: the fixture segments are %.4f and %.4f', short, long);
end

% an explicit length is the caller's business and must survive the cap
capped = arrowExtent(near);
explicit = arrowExtent(near,'length',16);
if ~(explicit > capped * 1.5)
  error(['check_arrowPlot: ''length'',16 gave a %.4f wide patch against '...
    '%.4f for the capped default - the explicit value was ignored'], ...
    explicit, capped);
end

disp('check_arrowPlot: passed');

end

% =========================================================================
function extent = arrowExtent(ori,varargin)
% widest distance across the drawn arrow patch

plotIPDF(ori(1),vector3d.Y,'antipodal','MarkerSize',4);
hold on
plotIPDF(ori(2),vector3d.Y,'antipodal','MarkerSize',4);
plotIPDF(ori,vector3d.Y,'arrow','tipAngle',5,varargin{:});
hold off
drawnow

ax = gca;
p = findall(ax,'type','patch');
V = p(1).Vertices;

d = pdist2(V,V);
extent = max(d(:));

close all

end

% =========================================================================
function cleanup(oldVis)
close all
set(0,'DefaultFigureVisible',oldVis);
end
