function S2F = permute(S2F, varargin)
% overloads permute

S2F.values = permute(S2F.values, [1 varargin{:}+1]);

end