function pf = plus(pf1,pf2)
% implements pf1 + pf2
%
% overload the + operator, i.e. one can now write pf1 + pf2 in order to
% add two pole figures
%
% See also
% PoleFigure_index PoleFigure/minus PoleFigure/mtimes


if isa(pf1,'PoleFigure')
  
  pf = pf1;
  
else
  
  pf = pf2;
  pf2 = pf1;
  
end

for i = 1:length(pf)
  if isa(pf2,'PoleFigure')
    pf(i).intensities = pf(i).intensities + pf2(i).intensities;
  else
    pf(i).intensities = pf(i).intensities + pf2;
  end
end
