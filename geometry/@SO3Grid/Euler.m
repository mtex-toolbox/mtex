function varargout = Euler(S3G,varargin)
% convert SO3Grid to Euler angles
%
%% Syntax
%
%  [phi1,Phi,phi2] = Euler(S3G,'Bunge');
%  abg = Euler(S3G);
%
%% Input
%  S3G - @SO3Grid
%
%% Options
%  ZYZ, ABG   - Matthies (alpha, beta, gamma) convention (default)
%  ZXZ, BUNGE - Bunge (phi1,Phi,phi2) convention %
% 
%% See also
% quaternion/Euler

% get convention
[convention,labels] = EulerAngleConvention(varargin{:});
S3GOptions = get(S3G,'options');
S3GConvention = EulerAngleConvention(S3GOptions);

if isempty(S3G.center) && checkEulerAngleConvention(S3GConvention,convention)
  
  if nargout == 3
    varargout{1} = vertcat(S3G.alphabeta(:,1));
    varargout{2} = vertcat(S3G.alphabeta(:,2));
    varargout{3} = vertcat(S3G.alphabeta(:,3));    
    
  elseif nargout == 1
    
    varargout{1} = vertcat(S3G.alphabeta);
    
  else
    
    d = vertcat(S3G.alphabeta)/degree;
    d(abs(d)<1e-10)=0;
  
    disp(' ');
    disp(['  ' convention ' Euler angles in degree'])
    cprintf(d,'-L','  ','-Lc',labels);
    disp(' ');
    
  end
    
else
  
  [varargout{1:nargout}] = Euler(quaternion(S3G),varargin{:});
  
end
