function b = eq(S1,S2,varargin)
% check S1 == S2

% the id names a group, the key tells two unnamed ones apart
b = S1.id == S2.id && S1.groupKey == S2.groupKey;

end
