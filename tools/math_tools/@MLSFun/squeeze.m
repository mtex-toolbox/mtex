function F = squeeze(F,varargin)
% overloads squeeze

s = size(F);
F = reshape(F,s(s ~= 1));

end
