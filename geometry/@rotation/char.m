function s = char(q,eps,varargin)
% quaternion to char

if nargin>1 && ~isnumeric(eps)
  varargin = [{eps},varargin];
  eps = 100;  
elseif nargin == 1
  eps = 100;
end

if length(q) == 1
  [alpha,beta,gamma] = Euler(q);
  if check_option(varargin,'nodegree')
    degchar = '';
  else
    degchar = mtexdegchar;
  end
  
  s = ['(',xnum2str(alpha/degree,eps),degchar,',',xnum2str(beta/degree,eps),...
    degchar,',',xnum2str(gamma/degree,eps),degchar,')'];
  
else
  s = ['Rotations: ',num2str(size(q,1)),'x',num2str(size(q,2))];
end
