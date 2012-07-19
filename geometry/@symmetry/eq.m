function b = eq(S1,S2)
% check S1 == S2

b = strcmp({S1.laue},{S2.laue}) && ...
  all(norm(S1.axis - S2.axis)./norm(S1.axis)<10^-2);
