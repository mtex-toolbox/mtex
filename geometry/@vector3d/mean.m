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
  
  varargin = delete_option(varargin,'antipodal');
  
  xx = mean(v.x.^2,varargin{:});
  xy = mean(v.x.*v.y,varargin{:});
  xz = mean(v.x.*v.z,varargin{:});
  yy = mean(v.y.^2,varargin{:});
  yz = mean(v.y.*v.z,varargin{:});
  zz = mean(v.z.^2,varargin{:});
  
  [m,~] = eig3(xx,xy,xz,yy,yz,zz,'largest');  
  
else
  m = sum(v,varargin{:});
end

m = m .normalize;

end
