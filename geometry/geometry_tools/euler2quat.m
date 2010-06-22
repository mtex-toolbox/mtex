function q = euler2quat(alpha,beta,gamma,varargin)
% converts euler angle to quaternion
%
%% Description
% The method *euler2quat* defines a [[quaternion_index.html,rotation]]
% by Euler angles. You can choose whether to use the Bunge (phi,psi,phi2) 
% convention or the Matthies (alpha,beta,gamma) convention.
%
%% Syntax
%
%  q = euler2quat(alpha,beta,gamma)
%  q = euler2quat(phi1,Phi,phi2,'Bunge')
%
%% Input
%  alpha, beta, gamma - double
%  phi1, Phi, phi2    - double
%
%% Output
%  q - @quaternion
%
%% Options
%  ABG, ZYZ   - Matthies (alpha, beta, gamma) convention (default)
%  BUNGE, ZXZ - Bunge (phi1,Phi,phi2) convention 
%
%% See also
% quaternion_index quaternion/quaternion axis2quat Miller2quat 
% vec42quat hr2quat idquaternion 


% if check_option(varargin,'BUNGE')
%   b = -cos((alpha-gamma)./2) .* sin(beta./2);
%   c = sin((alpha-gamma)./2) .* sin(beta./2);
%   d = -sin((alpha+gamma)./2) .* cos(beta./2);
%   a = cos((alpha+gamma)./2) .* cos(beta./2);
% else
%   b = -cos((alpha-gamma)./2) .* sin(beta./2);
%   c = sin((alpha-gamma)./2) .* sin(beta./2);
%   d = -sin((alpha+gamma)./2) .* cos(beta./2);
%   a = cos((alpha+gamma)./2) .* cos(beta./2);
% end
% 
% q = quaternion(a,b,c,d);
% 
% return

%% transform to right convention

conventions = {'nfft','ZYZ','ABG','Matthies','Roe','Kocks','Bunge','ZXZ','Canova'};
convention = get_flag(varargin,conventions,get_mtex_option('EulerAngleConvention'));

switch convention
  
  case {'Matthies','nfft','ZYZ','ABG'}

  case 'Roe'
    
  case {'Bunge','ZXZ'}

    alpha = alpha + pi/2;
    gamma = gamma + 3*pi/2;
      
  case {'Kocks'}

    gamma = pi - gamma;
        
  case {'Canova'}
    
    alpha = pi/2 - alpha;
    gamma = 3*pi/2 - gamma;
        
end


%% construct quaternion

q = axis2quat(zvector,alpha).*...
  axis2quat(yvector,beta).*axis2quat(zvector,gamma);

