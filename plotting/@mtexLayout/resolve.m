function plan = resolve(lay,mtexFig,override)
% lay the figure out: measure, solve, apply, until the inset stops moving
%
% Syntax
%   plan = lay.resolve(mtexFig)
%   plan = lay.resolve(mtexFig,override)
%
% Input
%  override - spec fields to force, e.g. a pinned axis size, without writing
%             them onto the @mtexFigure and having them outlive this call
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

if nargin < 3, override = struct; end

plan = lay.lastPlan;
if lay.busy || lay.isHeld || isempty(mtexFig.children), return; end

lay.busy = true;
done = onCleanup(@() lay.clearBusy); %#ok<NASGU>

maxPasses = 3;

for pass = 1:maxPasses

  spec = lay.measure(mtexFig);
  for f = fieldnames(override).', spec.(f{1}) = override.(f{1}); end

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

% hand the results back to @mtexFigure, which is what everything outside this
% class still reads them from - setColorRange, the doc thumbnail generator,
% doc/Plasticity/TaylorHex and the plotting tests
mtexFig.ncols = plan.ncols;
mtexFig.nrows = plan.nrows;
mtexFig.axisWidth = plan.axisWidth;
mtexFig.axisHeight = plan.axisHeight;
mtexFig.tightInset = plan.inset;
mtexFig.figTightInset = plan.figInset;

end

% -------------------------------------------------------------------------
function setBusy(lay,tf)
lay.busy = tf;
end
