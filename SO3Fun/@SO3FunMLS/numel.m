function n = numel(SO3F)
% overloads numel

s = size(SO3F.values);
n = prod(s(2:end));

end