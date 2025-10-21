function n = numel(S2F)
% overloads numel

s = size(S2F.values);
n = prod(s(2:end));

end