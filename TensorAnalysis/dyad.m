function T = dyad(T,n,varargin)
% dyadic tensor product 
%
% Synatx
%
%   T = dyad(T1,T2)
%   T = dyad(T1,n)
%
% Input
%  T1, T2 - @tensor
%  n - power
%
% Output
%  T - @tensor
%


if ~isa(T,'tensor'), T = tensor(T); end

if nargin == 1
  
  % nothing todo
  
elseif isnumeric(n)

  if n == 1, return; end
  
  args = [repcell(T,1,n);mat2cell(1:(T.rank * n),1,T.rank*ones(1,n))];

  T = dyad(EinsteinSum(args{:}),varargin{:});
  
else
  
  if ~isa(n,'tensor'), n = tensor(n); end
  T = dyad(EinsteinSum(T,1:T.rank,n,T.rank + (1:n.rank)),varargin{:});
  
end
  


