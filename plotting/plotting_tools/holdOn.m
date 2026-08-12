function [guard,washeld] = holdOn(ax)
% incremental, nesting aware hold on
%
% Syntax
%   hG = holdOn(ax);            % hold ax until hG is cleared
%   [hG,washeld] = holdOn(ax);  % also report the previous hold state
%
% Description
% Switches hold on for the axes |ax| and returns a guard object. As soon as
% the guard is deleted - usually when the calling function returns, also in
% case of an error - the previous hold state is restored. Calls may be
% nested: only the outermost holdOn actually changes the axes.
%
% Note that the output has to be assigned to a variable. Calling holdOn as
% a bare statement leaves the guard in |ans|, where it is released at an
% unpredictable point - as soon as anything else overwrites |ans|.
%
% A function that hands out handles to its *nested* functions - typically as
% figure callbacks - keeps its whole workspace alive for as long as those
% handles exist, and with it the guard. Release it explicitly with
% |clear hG| in that case.
%
% Input
%  ax - axes handle(s)
%
% Output
%  guard   - @onCleanup object, keep it alive as long as hold is required
%  washeld - logical, was ax held before this call
%
% See also
% holdRelease getHoldState copyHoldState

if nargin == 0 || isempty(ax), ax = gca; end
ax = ax(isgraphics(ax,'axes'));

washeld = ~isempty(ax) && all(arrayfun(@ishold,ax));

for a = reshape(ax,1,[])

  n = getappdata(a,'mtexHoldCount');
  if isempty(n) || n <= 0
    % remember the state we have to return to
    setappdata(a,'mtexHoldState',{a.NextPlot,getappdata(a,'PlotHoldStyle')});
    n = 0;
  end
  setappdata(a,'mtexHoldCount',n+1);
  hold(a,'on');

end

guard = onCleanup(@() holdRelease(ax));

if nargout == 0
  warning('MTEX:holdOn',['The output of holdOn has to be assigned to a ' ...
    'variable - otherwise the guard ends up in ans and hold is released ' ...
    'at an unpredictable point.']);
end

end
