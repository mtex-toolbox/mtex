function check_colorbarLocation
% check that a colorbar ends up on the side it was asked for
%
% mtexFigure owns the axes position, so it repositions any colorbar on every
% layout pass. That code knew only two places to put one: a vertical bar to
% the right of the axes and a horizontal bar below them. A 'northoutside'
% bar was therefore laid out exactly like a 'southoutside' one and a
% 'westoutside' one like an 'eastoutside' one - the requested side was
% accepted, then quietly overruled.
%
% The side is now kept in mtexFig.cBarSide, the way mtexFig.legendSide
% already worked, read off the colorbar before any Position assignment
% switches its Location to 'manual'. calcTightInset reserves the band there
% and updateLayout puts the bar into it.

old = get(0,'DefaultFigureVisible');
cleanup = onCleanup(@() set(0,'DefaultFigureVisible',old));
set(0,'DefaultFigureVisible','off');

checkSingleAxis;
checkSeveralAxes;
checkOptionAndFlagAgree;

disp('check_colorbarLocation: passed');

end

% =========================================================================
function checkSingleAxis

for side = {'east','west','south','north'}
  [pos,box] = draw(1,{'location',[side{1} 'outside']});
  assertSide(pos,box,side{1},'single axis');
end

end

% -------------------------------------------------------------------------
function checkSeveralAxes
% three pole figures, i.e. the branch that lays out a raster of axes

for side = {'east','west','south','north'}
  [pos,box] = draw(3,{'location',[side{1} 'outside']});
  assertSide(pos,box,side{1},'three axes');
end

end

% -------------------------------------------------------------------------
function checkOptionAndFlagAgree
% 'location','northoutside' and a bare 'northoutside' are the same request

for side = {'east','west','south','north'}

  byOption = draw(1,{'location',[side{1} 'outside']});
  byFlag = draw(1,{[side{1} 'outside']});

  assert(isequal(round(byOption),round(byFlag)), ...
    'check_colorbarLocation: %s as an option gives %s, as a flag %s', ...
    side{1}, mat2str(round(byOption)), mat2str(round(byFlag)))

end

end

% =========================================================================
function [pos,box] = draw(nPF,opts)
% a pole figure plot with nPF pole figures and a colorbar; returns the
% position of the first colorbar and the bounding box of all axes, read
% before the figure is closed - closing it deletes the handles

odf = SO3FunRBF(orientation.rand(5,crystalSymmetry('m-3m')), ...
  SO3DeLaValleePoussinKernel('halfwidth',15*degree));

hkl = {Miller(1,0,0,odf.CS), Miller({1,0,0},{1,1,0},{1,1,1},odf.CS)};
h = hkl{1 + (nPF > 1)};

figure
plotPDF(odf,h,'contourf');
cb = mtexColorbar(opts{:});

mf = gcm();
b = cell2mat(get(mf.children(:),{'Position'}));
box = [min(b(:,1)), max(b(:,1)+b(:,3)), min(b(:,2)), max(b(:,2)+b(:,4))];
pos = cb(1).Position;

close all force

end

% -------------------------------------------------------------------------
function assertSide(pos,box,side,what)
% the colorbar has to sit outside the axes on the requested side

l = pos(1); r = pos(1)+pos(3);
b = pos(2); t = pos(2)+pos(4);

switch side
  case 'east'
    ok = l >= box(1);       % right of where the axes start
    where = sprintf('left edge %.0f, axes start at %.0f',l,box(1));
  case 'west'
    ok = r <= box(1);       % left of all axes
    where = sprintf('right edge %.0f, axes start at %.0f',r,box(1));
  case 'south'
    ok = t <= box(3);       % below all axes
    where = sprintf('top edge %.0f, axes start at %.0f',t,box(3));
  case 'north'
    ok = b >= box(4);       % above all axes
    where = sprintf('bottom edge %.0f, axes end at %.0f',b,box(4));
end

assert(ok, 'check_colorbarLocation: %s, %soutside colorbar has its %s', ...
  what, side, where)

% and it has to be inside the figure
assert(l > 0 && b > 0, ...
  'check_colorbarLocation: %s, %soutside colorbar sits outside the figure at [%.0f %.0f]', ...
  what, side, l, b)

end
