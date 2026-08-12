function check_holdGuard
% check the incremental (nesting aware) hold mechanism itself
%
% Verifies that
%
% * a holdOn guard holds the axes and restores it when the guard dies -
%   also on an early return or an exception
% * nested guards compose, only the outermost one actually releases
% * an explicit hold off by the caller wins over a pending guard
% * the exact NextPlot value is restored, not just 'replace'
% * arrays of axes and deleted axes are handled
% * calling holdOn without an output argument warns
%
% This is a control flow and state machine test that happens to need an
% axes; it needs no data and no MTEX plot, which is why it is in core while
% the sweep over every MTEX plot function is plotting/check_holdStatePlots.
%
% Figures are made invisible and closed by runTests, so this file does not
% manage DefaultFigureVisible itself.
%
% See also
% holdOn holdRelease copyHoldState check_holdStatePlots

% ---------------------------------------------------------------- 1 basics
ax = freshAxes;
if takeAndDrop(ax) == false
  error('check_holdState: the guard did not hold the axes');
end
if ishold(ax)
  error('check_holdState: hold was not released when the guard died');
end

% --------------------------------------------------------------- 2 nesting
ax = freshAxes;
hOuter = holdOn(ax); %#ok<NASGU>
if ~ishold(ax), error('check_holdState: the outer guard did not hold'); end
takeAndDrop(ax);
if ~ishold(ax)
  error('check_holdState: an inner guard released a hold it did not take');
end
clear hOuter
if ishold(ax)
  error('check_holdState: the outer guard did not release after nesting');
end

% ---------------------------------------------------------- 3 error safety
ax = freshAxes;
try
  throwWhileHolding(ax);
  error('check_holdState: throwWhileHolding did not throw');
catch ME
  if ~strcmp(ME.identifier,'MTEX:test:boom'), rethrow(ME); end
end
if ishold(ax)
  error('check_holdState: hold survived an exception');
end

% ----------------------------------------------------------- 4 early return
ax = freshAxes;
returnEarly(ax);
if ishold(ax)
  error('check_holdState: hold survived an early return');
end

% ------------------------------------------------- 5 explicit hold off wins
ax = freshAxes;
hG = holdOn(ax); %#ok<NASGU>
hold(ax,'off');
clear hG
if ishold(ax)
  error('check_holdState: the guard switched hold back on after hold off');
end
% and the axes has to be usable again afterwards
hG = holdOn(ax); %#ok<NASGU>
if ~ishold(ax)
  error('check_holdState: holdOn does not work after an explicit hold off');
end
clear hG

% ---------------------------------------------- 6 exact NextPlot round trip
for state = {'replace','replaceChildren','add'}
  ax = freshAxes;
  ax.NextPlot = state{1};
  before = ax.NextPlot; % MATLAB lower cases the value it stores
  hG = holdOn(ax); %#ok<NASGU>
  clear hG
  if ~strcmp(ax.NextPlot,before)
    error('check_holdState: NextPlot ''%s'' was restored as ''%s''',...
      before, ax.NextPlot);
  end
end

% -------------------------------------------------- 7 arrays, deleted axes
f = figure; ax = [subplot(1,2,1,'parent',f), subplot(1,2,2,'parent',f)];
hG = holdOn(ax); %#ok<NASGU>
if ~all(arrayfun(@ishold,ax))
  error('check_holdState: not all axes of the array were held');
end
clear hG
if any(arrayfun(@ishold,ax))
  error('check_holdState: not all axes of the array were released');
end

f = figure; ax = axes(f);
hG = holdOn(ax); %#ok<NASGU>
close(f)
try
  clear hG
catch ME
  error('check_holdState: releasing a deleted axes failed - %s',ME.message);
end

% ------------------------------------------------- 8 bare statement warning
ax = freshAxes;
w = warning('off','MTEX:holdOn');
lastwarn('','');
holdOn(ax);
[~,id] = lastwarn;
warning(w);
clear ans % the guard the bare call left behind in ans
if ~strcmp(id,'MTEX:holdOn')
  error('check_holdState: holdOn without output argument did not warn');
end

close all

disp('check_holdGuard: ok')

end

% -------------------------------------------------------------------------
function ax = freshAxes
close all
figure;
ax = gca;
ax.NextPlot = 'replace';
end

function washeld = takeAndDrop(ax)
% take a guard, report whether the axes is held while it is alive

hG = holdOn(ax); %#ok<NASGU>
washeld = ishold(ax);

end

function throwWhileHolding(ax)

hG = holdOn(ax); %#ok<NASGU>
error('MTEX:test:boom','boom');

end

function returnEarly(ax)

hG = holdOn(ax); %#ok<NASGU>
if ishold(ax), return; end
error('check_holdState: unreachable');

end

