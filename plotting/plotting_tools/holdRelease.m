function holdRelease(ax)
% release an incremental hold
%
% Syntax
%   holdRelease(ax)
%
% Description
% Counterpart of <holdOn.html holdOn>. Decreases the hold counter of the
% axes |ax| and restores the original hold state once it drops back to
% zero. Usually this is called automatically by the guard returned from
% holdOn and there is no need to call it directly.
%
% Input
%  ax - axes handle(s)
%
% See also
% holdOn getHoldState copyHoldState

if nargin == 0 || isempty(ax), ax = gca; end

% the axes might have been deleted while the guard was alive
ax = ax(isgraphics(ax,'axes'));

for a = reshape(ax,1,[])

  n = getappdata(a,'mtexHoldCount');
  if isempty(n) || n <= 0, continue; end % nothing outstanding

  n = n - 1;
  setappdata(a,'mtexHoldCount',n);
  if n > 0, continue; end % still held by an outer holdOn

  state = getappdata(a,'mtexHoldState');
  setappdata(a,'mtexHoldState',[]);
  if isempty(state), continue; end

  % somebody explicitly switched hold off in between - respect that
  if ~ishold(a), continue; end

  a.NextPlot = state{1};
  if isempty(state{2})
    if isappdata(a,'PlotHoldStyle'), rmappdata(a,'PlotHoldStyle'); end
  else
    setappdata(a,'PlotHoldStyle',state{2});
  end

end

end
