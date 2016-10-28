function s = char(q,varargin)
% quaternion to char

if length(q) == 1
  [alpha,beta,gamma] = Euler(q);
  if check_option(varargin,'nodegree')
    degchar = '';
  else
    degchar = mtexdegchar;
  end
  
  s = ['(',xnum2str(alpha/degree,1e-3),degchar,',',xnum2str(beta/degree,1e-3),...
    degchar,',',xnum2str(gamma/degree,1e-3),degchar,')'];
  
else
  s = ['Rotations: ',num2str(size(q,1)),'x',num2str(size(q,2))];
end
