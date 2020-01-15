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
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%

v = v.normalize;
if check_option(varargin,'antipodal') || v.antipodal

  varargin = delete_option(varargin,'antipodal');

  if check_option(varargin,'weights')
    
    w = get_option(varargin,'weights');
    
    xx = mean(w .* v.x.^2,  varargin{:});
    xy = mean(w .* v.x.*v.y,varargin{:});
    xz = mean(w .* v.x.*v.z,varargin{:});
    yy = mean(w .* v.y.^2,  varargin{:});
    yz = mean(w .* v.y.*v.z,varargin{:});
    zz = mean(w .* v.z.^2,  varargin{:});
    
  else
    
    xx = mean(v.x.^2,  varargin{:});
    xy = mean(v.x.*v.y,varargin{:});
    xz = mean(v.x.*v.z,varargin{:});
    yy = mean(v.y.^2,  varargin{:});
    yz = mean(v.y.*v.z,varargin{:});
    zz = mean(v.z.^2,  varargin{:});
    
  end

  [m,~] = eig3(xx,xy,xz,yy,yz,zz,'largest');

else
  
  if check_option(varargin,'weights')
    v = v .* get_option(varargin,'weights');
  end
    
  m = sum(v,varargin{:});
end

m = m .normalize;

end
