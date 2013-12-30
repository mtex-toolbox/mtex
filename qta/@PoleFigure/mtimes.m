function npf = mtimes(arg1,arg2)
% scaling of PoleFigures, implements pf1 * b and a * pf2
%
% overload the * operator, i.e. one can now write x * pf in order to
% scale the @PoleFigure pf by the factor x 
%
% See also
% PoleFigure_index PoleFigure/plus PoleFigure/minus


if ~isa(arg2,'PoleFigure') || ...
    (isa(arg1,'PoleFigure') && length(arg1) > length(arg2))
  pf = arg1;
  m = arg2;
else
  pf = arg2;
  m = arg1;
end

if isa(m,'double')
  npf = scale(pf,m);
elseif isa(m,'quaternion')
  npf = rotate(pf,m);
elseif isa(m,'PoleFigure')
  npf = pf;
  for i = 1:length(pf)
    npf(i).intensities = pf(i).intensities .* m.intensities;
  end
end
