function check_mtexLayout
% the layout arithmetic, without a figure
%
% mtexLayout.solveLayout takes no graphics handle and returns none, so
% everything the layout decides can be checked here rather than by rendering
% a plot and reading positions back. That is the point of splitting it out:
% the old layout could only be tested through a figure, and was not.

checkGrid;
checkAspectRatio;
checkFitsInFigure;
checkUserLayout;
checkFixedHeight;
checkMaxSize;
checkGridUnderBound;
checkColorbarSides;
checkGlobalColorbarSingleAxis;
checkLegendSides;
checkInsetApplies;

disp('check_mtexLayout: passed');

end

% =========================================================================
function checkGrid
% every axes gets a cell, all cells the same size, none overlapping

for n = 1:8

  plan = mtexLayout.solveLayout(struct('n',n,'figSize',[800 600]));

  assert(size(plan.pos,1) == n, ...
    'check_mtexLayout: %d axes but %d positions',n,size(plan.pos,1))

  assert(plan.ncols*plan.nrows >= n, ...
    'check_mtexLayout: %d axes do not fit a %dx%d grid',n,plan.nrows,plan.ncols)

  assert(all(plan.pos(:,3) == plan.axisWidth) && ...
    all(plan.pos(:,4) == plan.axisHeight), ...
    'check_mtexLayout: axes came out different sizes for n=%d',n)

  assertNoOverlap(plan.pos,sprintf('n=%d',n));

end

end

% -------------------------------------------------------------------------
function checkAspectRatio
% with keepAspectRatio the axes is shaped by ratio, without it it fills

for ratio = [0.5 1 2]
  plan = mtexLayout.solveLayout(struct('n',3,'ratio',ratio,'figSize',[900 700]));
  got = plan.axisHeight / plan.axisWidth;
  assert(abs(got - ratio) < 0.02, ...
    'check_mtexLayout: asked for ratio %g, got %g',ratio,got)
end

wide = mtexLayout.solveLayout(struct('n',1,'ratio',1, ...
  'keepAspectRatio',false,'figSize',[900 300]));
assert(wide.axisWidth > wide.axisHeight, ...
  'check_mtexLayout: without keepAspectRatio the axes should fill the figure')

end

% -------------------------------------------------------------------------
function checkFitsInFigure
% nothing the layout places may hang off the figure

figSize = [800 600];

for n = [1 2 3 4 6]
  for side = {'east','west','north','south'}

    plan = mtexLayout.solveLayout(struct('n',n,'figSize',figSize, ...
      'cBar',struct('n',1,'side',side{1},'thickness',15,'gap',10,'labelRoom',40)));

    assertInside(plan.pos,figSize,sprintf('axes, n=%d, %s bar',n,side{1}));
    assertInside(plan.cBarPos,figSize,sprintf('colorbar, n=%d, %s',n,side{1}));

  end
end

end

% -------------------------------------------------------------------------
function checkUserLayout
% an explicit grid is obeyed, and grown rather than dropping axes

plan = mtexLayout.solveLayout(struct('n',6,'layoutMode','user', ...
  'nrows',2,'ncols',3,'figSize',[800 600]));
assert(plan.nrows == 2 && plan.ncols == 3, ...
  'check_mtexLayout: asked for 2x3, got %dx%d',plan.nrows,plan.ncols)

% a grid too small must not silently lose axes
plan = mtexLayout.solveLayout(struct('n',7,'layoutMode','user', ...
  'nrows',2,'ncols',2,'figSize',[800 600]));
assert(plan.ncols*plan.nrows >= 7 && size(plan.pos,1) == 7, ...
  'check_mtexLayout: 7 axes into a 2x2 user grid lost some')

end

% -------------------------------------------------------------------------
function checkFixedHeight
% a fixed height wins over the space available, and the figure grows to fit

h = 250;
for n = [1 3 6]

  plan = mtexLayout.solveLayout(struct('n',n,'ratio',1, ...
    'fixedAxisHeight',h,'figSize',[400 300]));

  assert(all(plan.pos(:,4) == h), ...
    'check_mtexLayout: fixed height %g not honoured for n=%d',h,n)

  assert(plan.figSize(2) >= h, ...
    'check_mtexLayout: figure %g too short for a fixed axis height %g', ...
    plan.figSize(2),h)

  % the reported size has to actually hold the axes it planned
  assertInside(plan.pos,plan.figSize,sprintf('fixed height, n=%d',n));

end

end

% -------------------------------------------------------------------------
function checkMaxSize
% a fixed height is a maximum: a grid that would not fit the screen scales down
%
% A figure larger than the screen is one the window manager shrinks, and a
% snapshot taken of that squeezes the figure into the wrong shape - which is
% how it reaches a published page.

h = 370;

% room enough: the height is honoured to the pixel
roomy = mtexLayout.solveLayout(struct('n',6,'ratio',1,'fixedAxisHeight',h, ...
  'figSize',[400 300],'maxSize',[1920 1120]));

assert(all(roomy.pos(:,4) == h), ...
  'check_mtexLayout: fixed height %g not honoured although it fits, got %g', ...
  h,roomy.axisHeight)

% too little room: the axes give way, and the figure stays inside the bound
for maxSize = {[900 700],[1920 500],[600 1200]}

  m = maxSize{1};
  plan = mtexLayout.solveLayout(struct('n',6,'ratio',1,'fixedAxisHeight',h, ...
    'figSize',[400 300],'maxSize',m));

  assert(plan.axisHeight <= h, ...
    'check_mtexLayout: axes grew past the fixed height %g to %g',h,plan.axisHeight)

  assert(all(plan.figSize <= m + 1), ...
    'check_mtexLayout: figure %s exceeds the bound %s', ...
    mat2str(round(plan.figSize)),mat2str(m))

  assertInside(plan.pos,plan.figSize,sprintf('bounded by %s',mat2str(m)));

end

end

% -------------------------------------------------------------------------
function checkGridUnderBound
% under a bound the grid is the one that keeps the axes largest
%
% Wide axes in one long row make every one of them small, so four sections of
% ratio 1:4 belong on two rows. Square ones do not gain from stacking.

wide = mtexLayout.solveLayout(struct('n',4,'ratio',0.25,'fixedAxisHeight',370, ...
  'figSize',[400 300],'maxSize',[1920 1120]));

assert(wide.nrows > 1, ...
  'check_mtexLayout: four axes of ratio 1:4 came out %dx%d, one row of them ', ...
  wide.ncols,wide.nrows)

square = mtexLayout.solveLayout(struct('n',6,'ratio',1,'fixedAxisHeight',370, ...
  'figSize',[400 300],'maxSize',[1920 1120]));

assert(square.ncols == 3 && square.nrows == 2, ...
  'check_mtexLayout: six square axes came out %dx%d rather than 3x2', ...
  square.ncols,square.nrows)

end

% -------------------------------------------------------------------------
function checkColorbarSides
% a bar goes outside the axes on the side it was asked for, all four of them

for n = [1 3]
  for side = {'east','west','north','south'}

    plan = mtexLayout.solveLayout(struct('n',n,'figSize',[800 600], ...
      'cBar',struct('n',1,'side',side{1},'thickness',15,'gap',10)));

    assertSide(plan.cBarPos,plan.pos,side{1}, ...
      sprintf('global bar, n=%d',n));

  end
end

% one bar per axes, each against its own axes
plan = mtexLayout.solveLayout(struct('n',3,'figSize',[800 600], ...
  'cBar',struct('n',3,'side','east','thickness',15,'gap',10)));

assert(size(plan.cBarPos,1) == 3, ...
  'check_mtexLayout: 3 axes but %d bars',size(plan.cBarPos,1))

for i = 1:3
  assertSide(plan.cBarPos(i,:),plan.pos(i,:),'east', ...
    sprintf('per-axes bar %d',i));
end

end

% -------------------------------------------------------------------------
function checkGlobalColorbarSingleAxis
% the case the old layout skipped outright: its `isscalar(cBarAxis) && i>1`
% guard read a leaked loop variable, so a one-axes figure never placed its
% global colorbar at all

plan = mtexLayout.solveLayout(struct('n',1,'figSize',[600 500], ...
  'cBar',struct('n',1,'side','east','thickness',15,'gap',10)));

assert(~isempty(plan.cBarPos), ...
  'check_mtexLayout: a single axes got no global colorbar')

assertSide(plan.cBarPos,plan.pos,'east','single axis global bar');

end

% -------------------------------------------------------------------------
function checkLegendSides

for side = {'east','west','north','south'}

  plan = mtexLayout.solveLayout(struct('n',4,'figSize',[900 700], ...
    'legend',struct('size',[90 60],'side',side{1},'spacing',10)));

  assert(~isempty(plan.legendPos),'check_mtexLayout: no legend placed')
  assertSide(plan.legendPos,plan.pos,side{1},'legend');
  assertInside(plan.legendPos,[900 700],['legend ' side{1}]);

end

end

% -------------------------------------------------------------------------
function checkInsetApplies
% one band, measured on the reference axes, has to leave room around every
% axes - decorations included, and still inside the figure

figSize = [900 700];
band = [40 30 10 20];

plan = mtexLayout.solveLayout(struct('n',4,'inset',band,'figSize',figSize));

assert(isequal(plan.inset,band), ...
  'check_mtexLayout: band came out %s, not %s',mat2str(plan.inset),mat2str(band))

grown = plan.pos + [-band(1) -band(2) 0 0] + ...
  [0 0 band(1)+band(3) band(2)+band(4)];
assertInside(grown,figSize,'axes with decorations');
assertNoOverlap(grown,'axes with decorations');

% given several, the widest wins: mtexFigure passes one, but nothing here
% should quietly under-reserve if it ever passes more
several = repmat(band,3,1);
several(3,:) = [60 60 60 60];
plan = mtexLayout.solveLayout(struct('n',3,'inset',several,'figSize',figSize));
assert(all(plan.inset == [60 60 60 60]), ...
  'check_mtexLayout: band is %s, not wide enough for the worst axes', ...
  mat2str(plan.inset))

end

% =========================================================================
function assertNoOverlap(pos,what)

for i = 1:size(pos,1)
  for j = i+1:size(pos,1)
    gapX = pos(i,1) >= pos(j,1)+pos(j,3) || pos(j,1) >= pos(i,1)+pos(i,3);
    gapY = pos(i,2) >= pos(j,2)+pos(j,4) || pos(j,2) >= pos(i,2)+pos(i,4);
    assert(gapX || gapY, ...
      'check_mtexLayout: %s, axes %d and %d overlap',what,i,j)
  end
end

end

% -------------------------------------------------------------------------
function assertInside(pos,figSize,what)

if isempty(pos), return; end

assert(all(pos(:,1) >= 0) && all(pos(:,2) >= 0), ...
  'check_mtexLayout: %s starts off the figure at %s',what, ...
  mat2str(round(min(pos(:,1:2),[],1))))

right = max(pos(:,1)+pos(:,3));
top = max(pos(:,2)+pos(:,4));
assert(right <= figSize(1)+1 && top <= figSize(2)+1, ...
  'check_mtexLayout: %s reaches [%.0f %.0f] in a %s figure', ...
  what,right,top,mat2str(figSize))

end

% -------------------------------------------------------------------------
function assertSide(pos,axesPos,side,what)
% pos has to sit outside the bounding box of axesPos, on the named side

ll = min(axesPos(:,1:2),[],1);
box = [ll, max(axesPos(:,1:2)+axesPos(:,3:4),[],1) - ll];

switch side
  case 'east'
    ok = pos(1) >= box(1)+box(3);
    got = sprintf('left edge %.0f, axes end at %.0f',pos(1),box(1)+box(3));
  case 'west'
    ok = pos(1)+pos(3) <= box(1);
    got = sprintf('right edge %.0f, axes start at %.0f',pos(1)+pos(3),box(1));
  case 'north'
    ok = pos(2) >= box(2)+box(4);
    got = sprintf('bottom edge %.0f, axes end at %.0f',pos(2),box(2)+box(4));
  case 'south'
    ok = pos(2)+pos(4) <= box(2);
    got = sprintf('top edge %.0f, axes start at %.0f',pos(2)+pos(4),box(2));
end

assert(ok,'check_mtexLayout: %s asked for %s but has its %s',what,side,got)

end
