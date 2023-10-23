function m = mode(v,varargin)
% computes the mode vector
%
% Syntax
%   % average direction with respect to the first nonsingleton dimension
%   m = mode(v)
%
%   % average direction along dimension d
%   m = mode(v,d)
%
%   % average axis
%   m = mode(v,'antipodal')
%
% Input
%  v - @vector3d
%
% Output
%  m - @vector3d
%
% Options
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  robust    - robust mode (with respect to outliers)
%


% robust estimator
if check_option(varargin,'robust') && length(v)>4
  
  varargin = delete_option(varargin,'robust');
  
  m = mode(v,varargin{:});
  
  omega = angle(m,v);
  id = omega < quantile(omega,0.8)*(1+1e-5);
  
  if any(id), m = mode(v.subSet(id),varargin{:}); end
  return;
end
  
if check_option(varargin,'antipodal') || v.antipodal

  varargin = delete_option(varargin,'antipodal');

  if check_option(varargin,'weights')
    v = v .* reshape(sqrt(get_option(varargin,'weights')),size(v));
    varargin = delete_option(varargin,'weights',1);
  end
    
  varargin = delete_option(varargin,'weights',1);
  
  xx = mode(v.x.^2,  varargin{:});
  xy = mode(v.x.*v.y,varargin{:});
  xz = mode(v.x.*v.z,varargin{:});
  yy = mode(v.y.^2,  varargin{:});
  yz = mode(v.y.*v.z,varargin{:});
  zz = mode(v.z.^2,  varargin{:});
  
  [m,~] = eig3(xx,xy,xz,yy,yz,zz,'largest');
else
  
  if check_option(varargin,'weights')
    v = v .* reshape(get_option(varargin,'weights'),size(v));
    varargin = delete_option(varargin,'weights',1);
    
    m = normalize(sum(v,varargin{:}));
    
  else
    
    v.x = mode(v.x,varargin{:});
    v.y = mode(v.y,varargin{:});
    v.z = mode(v.z,varargin{:});

    v.opt = struct;
    v.isNormalized = false;
    
    m = v;
  end
  
end

end
