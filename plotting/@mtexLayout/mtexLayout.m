classdef mtexLayout < handle
% the layout engine behind @mtexFigure
%
% Description
% Splits what @mtexFigure used to do in one pass into three, so that the
% arithmetic can be computed - and tested - without a figure:
%
%  measure -> spec   read the geometry off the graphics objects, once
%  solve   -> plan   pure arithmetic, no handles in and none out
%  apply             write back only what actually moved
%
% <mtexLayout.solveLayout.html solveLayout> is the middle step and is a
% static method: give it a spec struct and it returns every position,
% without a figure existing anywhere. That is what tests/core/check_mtexLayout
% exercises.
%
% See also
% mtexFigure mtexFigure/drawNow

methods (Static)
  plan = solveLayout(spec)
end

end
