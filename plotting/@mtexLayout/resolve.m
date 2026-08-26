function plan = resolve(lay,mtexFig)
% lay the figure out: measure, solve, apply, until the inset stops moving
%
% Syntax
%   plan = lay.resolve(mtexFig)
%
% Description
% The decoration band depends on the size of the axes - a wider axes gets
% different tick labels - so the layout is a fixed point rather than a
% single pass. @mtexFigure used to settle that by running the whole layout
% twice unconditionally, whatever the figure held. This iterates instead:
% the usual case converges after one pass and stops, and a case that would
% oscillate stops too.
%
% Re-entrant calls return the plan in hand. Writing an axes Position while
% laying out can bring the figure resize callback straight back round here,
% and it must not restart the layout underneath the pass that is running.
%
% See also
% mtexLayout/measure mtexLayout/apply mtexLayout/solveLayout

plan = lay.lastPlan;
if lay.busy || isempty(mtexFig.children), return; end

lay.busy = true;
done = onCleanup(@() lay.clearBusy); %#ok<NASGU>

maxPasses = 3;

for pass = 1:maxPasses

  spec = lay.measure(mtexFig);
  plan = mtexLayout.solveLayout(spec);
  plan.passes = pass;

  if ~lay.apply(mtexFig,plan), break; end

  % the axes moved, so the decorations may want different room than they did
  % when they were measured - the token carries the positions, so this reads
  % them again rather than answering from the cache
  after = lay.measure(mtexFig);

  if max(abs(max(after.inset,[],1) - max(spec.inset,[],1))) <= 1, break; end

end

lay.lastPlan = plan;

end

% -------------------------------------------------------------------------
function setBusy(lay,tf)
lay.busy = tf;
end
