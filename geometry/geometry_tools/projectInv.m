function [theta,rho] = projectInv(x,y,type)
% inverse spherical projection
%
%% Input
%  x,y  - coordinates
%  type - projection type
%
%% Output
% theta, rho - polar coodinates in radiant
%


%% plain projection
if strcmpi(type,'plain')
  rho = x .*  degree;
  theta = y.* degree;
  return
end

%% spherical projections

% radius
rqr = x.^2 + y.^2;

% angle
rho = atan2(y,x);

switch lower(type)
  
  case {'stereo','eangle'} % equal angle
    
    theta = atan(r)*2;
    
  case 'edist' % equal distance
    
    theta = r;

  case {'earea','schmidt'} % equal area

    theta = acos(1-rqr./2);
        
  case 'orthographic'

    theta = asin(r);
    
  otherwise
    
    error('Unknown Projection!')
    
end
