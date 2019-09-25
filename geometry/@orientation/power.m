function ori = power(ori,n)
% ori.^n
%
% Syntax
%   ori = ori.^n
%
% ori = ori^(-1)
% ori = ori.^2
% ori = ori.^[0,1,2,3]
%
%
% Input
%  ori - @rotation
%
% Output
%  ori - @rotation
%
% See also
% rotation/log 

if all(n == -1)
  ori = inv(ori);
elseif ori.CS ~= ori.SS
  error('The operation ^ is only applicable for misorientation between the same phase')
else
  ori = power@rotation(ori.project2FundamentalRegion,n);
end
