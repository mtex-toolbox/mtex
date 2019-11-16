function pf = plus(pf1,pf2)
% implements pf1 + pf2
%
% overload the + operator, i.e. one can now write pf1 + pf2 in order to
% add two pole figures
%
% See also
% PoleFigure/PoleFigure PoleFigure/minus PoleFigure/mtimes


if isa(pf1,'PoleFigure')
  pf = pf1;
else
  pf = pf2;
  pf2 = pf1;
end

if isa(pf2,'PoleFigure')
  for i = 1:pf.numPF
    pf.allI{i} = pf.allI{i} + pf2.allI{i};
    if ~all(isnull(angle(pf.allH{i},pf2.allH{i}),1e-4))
      pf.allH{i} = [pf.allH{i},pf2.allH{i}];
      pf.c{i} = [pf.c{i},pf2.c{i}];
    end
  end
else
  
  if numel(pf2) == length(pf) || length(pf2) == 1
    pf.intensities = pf.intensities + pf2;
  elseif numel(pf2) == length(pf.allH)
    for i = 1:pf.numPF
      pf.allI{i} = pf.allI{i} + pf2(i);
    end
  else
    error('MTEX: summation error')
  end 
end



