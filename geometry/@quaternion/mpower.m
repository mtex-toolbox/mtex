function qq = mpower(q,n)
% q^n
%
% Input
%  q - @quaternion
%
% Output
%  qq - @quaternion 
%
% See also
% quaternion/ctranspose

if n < 0, q = ctranspose(q);end

qq = 1;

for i = 1:abs(n)
  
  qq  = qq * q;
  
end

