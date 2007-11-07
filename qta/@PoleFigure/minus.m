function pf = minus(pf1,pf2)
% implements pf1 - pf2
%
% overload the - operator, i.e. one can now write pf1 - pf2 in order to
% subtract two pole figures from each other
%
%% See also
% PoleFigure_index PoleFigure/plus PoleFigure/mtimes

if isa(pf1,'PoleFigure')
  
  pf = pf1;
  sgn = 1;
  
else
  
  pf = pf2;
  pf2 = pf1;
  sgn = -1;
  
end

for i = 1:length(pf)
  if isa(pf2,'PoleFigure')
    pf(i).data = sgn * (pf(i).data - pf2(i).data);
  else
    pf(i).data = sgn * (pf(i).data - pf2);
  end
end
