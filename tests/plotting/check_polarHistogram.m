function check_polarHistogram
% check that a polar histogram of directions follows the plotting convention
%
% vector3d/histogram hands the convention to plottingConvention/setView,
% whose polaraxes branch sets ThetaZeroLocation and ThetaDir. It took the
% angle FROM east TO x about z, while ThetaZeroLocation asks where theta = 0
% - i.e. the x axis of the data - is drawn on screen, which is the angle the
% other way round. The two agree at 0 and 180 degree and swap top and
% bottom, so three of the four axis aligned conventions looked right and
% 'x↑→y' was rotated by exactly 180 degree.
%
% The assertion is on where a cluster of directions actually lands on
% screen, resolving ThetaZeroLocation and ThetaDir back into an angle,
% rather than on those two properties - it is their combination that decides
% what the reader sees.
%
% See also
% vector3d/histogram plottingConvention/setView grain2d/longAxis

oldVis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanUp = onCleanup(@() cleanup(oldVis)); %#ok<NASGU>

for conv = {'y↑→x','y↓→x','x←↑y','x↑→y'}

  pC = plottingConvention(conv{1});

  for d = {vector3d.X, vector3d.Y}

    % a tight cluster around one axis, so the peak bin is unambiguous
    v = normalize(d{1} + 0.02*vector3d.rand(300,1));
    v.how2plot = pC;

    h = histogram(v);
    drawnow

    [~,i] = max(h.BinCounts);
    theta = 0.5*(h.BinEdges(i) + h.BinEdges(i+1));

    got = screenAngle(h.Parent,theta);
    want = atan2(dot(d{1},pC.north,'noAntipodal'), dot(d{1},pC.east,'noAntipodal'));

    dev = abs(mod(got - want + pi, 2*pi) - pi);
    if dev > 10*degree
      error(['check_polarHistogram: %s - a cluster along %s peaks at %.1f ' ...
        'degree on screen, expected %.1f (ThetaZeroLocation %s, ThetaDir %s)'], ...
        conv{1}, char(round(d{1})), mod(got,2*pi)/degree, mod(want,2*pi)/degree, ...
        h.Parent.ThetaZeroLocation, h.Parent.ThetaDir);
    end

    close all
  end
end

disp('check_polarHistogram: passed');

end

% =========================================================================
function a = screenAngle(ax,theta)
% the on screen angle, counterclockwise from east, a bin at theta is drawn at

switch ax.ThetaZeroLocation
  case 'right',  zero = 0;
  case 'top',    zero = pi/2;
  case 'left',   zero = pi;
  case 'bottom', zero = 3*pi/2;
end

if strcmp(ax.ThetaDir,'counterclockwise')
  a = zero + theta;
else
  a = zero - theta;
end

end

% =========================================================================
function cleanup(oldVis)
close all
set(0,'DefaultFigureVisible',oldVis);
end
