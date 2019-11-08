function s = char(q,eps,varargin)
% quaternion to char

if nargin>1 && ~isnumeric(eps)
  varargin = [{eps},varargin];
  eps = 1;  
elseif nargin == 1
  eps = 1;
end

if length(q) == 1
  [alpha,beta,gamma] = Euler(q);
  if check_option(varargin,'nodegree')
    degchar = '';
  else
    degchar = mtexdegchar;
  end

  s = ['(' xnum2str([alpha,beta,gamma]./degree,...
    'precision',eps,'delimiter',[degchar ',']) degchar ')'];

else
  s = ['Rotations: ',size2str(q)];
end
