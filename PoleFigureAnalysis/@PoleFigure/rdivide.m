function pf = rdivide(arg1,arg2)
% implements pf1 ./ b and a ./ pf2
%
% overload the .* operator, i.e. one can now write x .* pf in order to
% scale the @PoleFigure pf by the factor x 
%
% See also
% PoleFigure/PoleFigure PoleFigure/plus PoleFigure/minus

if isa(arg2,'double')
  arg2 = 1./arg2;
else
  for i = 1:arg2.numPF, arg2.allI{i} = 1./arg2.allI{i};end
end

pf = arg1 .* arg2;
