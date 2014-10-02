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

for i = 1:pf.numPF
  if isa(pf2,'PoleFigure')
    pf.allI{i} = pf.allI{i} + pf2.allI{i};
    if ~all(isnull(angle(pf.allH{i},pf2.allH{i})))
      pf.allH{i} = [pf.allH{i},pf2.allH{i}];
      pf.c = [pf.c{i},pf2.c{i}];
    end
  else
    pf.allI{i} = pf.allI{i} + pf2;
  end
end
