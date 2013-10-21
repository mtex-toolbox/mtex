function pf = copy(pf,condition)
% extract points from pole figures
%
% A new set of pole figures is constrcuted from the initial pole figures by
% including only the points specified by condition
%
% Syntax  
%   pf  = copy(pf,condition)
%
% Input
%  pf         - @PoleFigure
%  condition  - condition / index set
%
% Output
%  pf - @PoleFigure
%
% See also
% PoleFigure/get PoleFigure/delete PoleFigure/set PoleFigure_index

if isnumeric(condition),
  inds = false(sum(GridLength(pf)),1);
  inds(condition) = true;
  condition = inds;
end

pf = delete(pf,~condition);
