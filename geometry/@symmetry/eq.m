function b = eq(S1,S2)
% check S1 == S2

b = strcmp({S1.laueGroup},{S2.laueGroup}) && ...
  all(norm(S1.axes - S2.axes)./norm(S1.axes)<10^-2);
