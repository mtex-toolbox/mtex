function pf = times(arg1,arg2)
% implements pf1 .* b and a .* pf2
%
% overload the .* operator, i.e. one can now write x .* pf in order to
% scale the @PoleFigure pf by the factor x 
%
% See also
% PoleFigure/PoleFigure PoleFigure/plus PoleFigure/minus

if isa(arg1,'PoleFigure') 
  pf = arg1;
  m = arg2;
else
  pf = arg2;
  m = arg1;
end

if isa(m,'double')
  pf = scale(pf,m);
elseif isa(m,'quaternion')
  pf = rotate(pf,m);
elseif isa(m,'PoleFigure')
  for i = 1:pf.numPF, pf.allI{i} = pf.allI{i} .* m.allI{i}; end
end
