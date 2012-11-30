function qq = power(q,n)
% q.^n
%
%% Input
%  q - @quaternion
%
%% Output
%  qq - @quaternion 
%
%% See also
% quaternion/ctranspose

if n < 0, q = ctranspose(q);end

qq = q;

for i = 2:abs(n)
  
  qq  = qq .* q;
  
end


% 04747874527
