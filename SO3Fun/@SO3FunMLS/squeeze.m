function SO3F = squeeze(SO3F, varargin)
% overloads squeeze

s = size(SO3F);
s = s(s~=1);
SO3F = reshape(SO3F,s);

end
