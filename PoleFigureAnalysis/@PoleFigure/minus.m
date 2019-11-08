function pf = minus(pf1,pf2)
% implements pf1 - pf2
%
% overload the - operator, i.e. one can now write pf1 - pf2 in order to
% subtract two pole figures from each other
%
% See also
% PoleFigure/PoleFigure PoleFigure/plus PoleFigure/mtimes

pf = pf1 + (-pf2);
