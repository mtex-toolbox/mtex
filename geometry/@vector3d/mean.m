function m = mean(v,varargin)
% computes the mean vector 
%
% Syntax
%   % average direction with respect to the first nonsingleton dimension
%   m = mean(v)   
%   
%   % average direction along dimension d
%   m = mean(v,d)
%
%   % average axis
%   m = mean(v,'antipodal')
%
% Input
%  v - @vector3d
%
% Output
%  m - @vector3d
%
% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
% 

v = v.normalize;
if check_option(varargin,'antipodal') || v.antipodal
  
  % find first non singular dimension
  if isnumeric(varargin{1}),
    d = varargin{1};
  else
    d = find(size(v.x)~=1, 1 );     
  end
  
  M = [v.x(:) v.y(:) v.z(:)];
  M = M.' * M;
  [u,~,~] = svds(M,1);
  m = vector3d(u(1),u(2),u(3));
  
else
  m = sum(v,varargin{:});
end

m = m .normalize;
