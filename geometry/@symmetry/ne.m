function b = ne(S1,S2)
% check S1 == S2

b = ~strcmp({S1.laue},{S2.laue});
