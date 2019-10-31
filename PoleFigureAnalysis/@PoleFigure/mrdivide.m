function pf = mrdivide(arg1,arg2)
% implements pf1 ./ b and a ./ pf2
%
% overload the .* operator, i.e. one can now write x .* pf in order to
% scale the @PoleFigure pf by the factor x 
%
% See also
% PoleFigure/PoleFigure PoleFigure/plus PoleFigure/minus

pf = arg1 ./ arg2;
