function b = eq(S1,S2,varargin)
% check S1 == S2

b = eq@handle(S1,S2) || S1.id == S2.id;
