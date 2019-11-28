function n = ndims(F,varargin) 
% overloads ndims

n = ndims(F.fhat,varargin{:})-1;
