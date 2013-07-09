function s = char(q,varargin)
% quaternion to char

if length(q) == 1
  [alpha,beta,gamma] = Euler(q);
  s = ['(',int2str(alpha/degree),mtexdegchar,',',int2str(beta/degree),mtexdegchar,',',int2str(gamma/degree),mtexdegchar,')'];
else
  s = ['Rotations: ',num2str(size(q,1)),'x',num2str(size(q,2))];
end
