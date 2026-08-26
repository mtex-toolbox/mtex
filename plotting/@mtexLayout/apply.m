function moved = apply(lay,mtexFig,plan)
% write the plan back, but only what actually moved
%
% Syntax
%   moved = lay.apply(mtexFig,plan)
%
% Output
%  moved - whether anything was written
%
% Description
% Every Position write on an axes fires listeners - scaleBar keeps one on
% Position and rebuilds itself from it - and a write during a resize can
% bring the resize callback straight back round. Skipping the writes that
% would not change anything is what keeps both quiet.
%
% See also
% mtexLayout/measure mtexLayout/solveLayout

moved = false;

ax = mtexFig.children(:);
ax = ax(isgraphics(ax));

moved = write(ax,plan.pos) || moved;
moved = write(mtexFig.cBarAxis(:),plan.cBarPos) || moved;
moved = write(mtexFig.legendAxis(:),plan.legendPos) || moved;

end

% =========================================================================
function moved = write(h,pos)
% set Position on those of h that are further than half a pixel from pos

moved = false;

h = h(isgraphics(h));
if isempty(h) || isempty(pos), return; end

n = min(numel(h),size(pos,1));
h = h(1:n); pos = pos(1:n,:);

pos(pos < 0) = 0;

old = cell2mat(get(h,{'Position'}));
stale = any(abs(old - pos) > 0.5, 2);
if ~any(stale), return; end

% one set for all of them rather than one call each
set(h(stale),{'Position'},num2cell(pos(stale,:),2));
moved = true;

end
