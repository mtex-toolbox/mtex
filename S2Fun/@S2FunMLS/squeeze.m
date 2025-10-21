function S2F = squeeze(S2F, varargin)
% overloads squeeze

s = size(S2F);
s = s(s~=1);
S2F = reshape(S2F,s);

end
