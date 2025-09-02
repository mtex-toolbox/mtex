function l = length(S2F)
% overloads length

s = size(S2F.values);
l = prod(s(2:end));

end