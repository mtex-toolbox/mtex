function npf = mrdivide(arg1,arg2)
% implements pf1 .* b and a .* pf2
%
% overload the .* operator, i.e. one can now write x .* pf in order to
% scale the @PoleFigure pf by the factor x 
%
% See also
% PoleFigure_index PoleFigure/plus PoleFigure/minus

if isa(arg1,'double')
  npf = arg2;
  for i = 1:length(arg2)
    npf(i).intensities = arg1(i) ./ arg2(i).intensities;
  end
elseif isa(arg2,'double')
  npf = arg1;
  for i = 1:length(arg1)
    npf(i).intensities = arg1(i).intensities ./ arg2(i);
  end
elseif isa(arg1,'PoleFigure') && isa(arg2,'PoleFigure')
  npf = arg1;
  for i = 1:length(arg1)
    npf(i).intensities = arg1(i).intensities ./ arg2(i).intensities;
  end
end
