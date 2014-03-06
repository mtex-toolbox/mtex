function s = char(q,varargin)
% quaternion to char

if length(q) == 1
  [alpha,beta,gamma] = Euler(q);
  if check_option(varargin,'nodegree')
    degchar = '';
  else
    degchar = mtexdegchar;
  end
  
  s = ['(',int2str(alpha/degree),degchar,',',int2str(beta/degree),degchar,',',int2str(gamma/degree),degchar,')'];
  
else
  s = ['Rotations: ',num2str(size(q,1)),'x',num2str(size(q,2))];
end
