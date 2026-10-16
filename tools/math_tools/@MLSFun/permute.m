function F = permute(F,varargin)
% overloads permute

F.values = permute(F.values,[1 varargin{:}+1]);

end
