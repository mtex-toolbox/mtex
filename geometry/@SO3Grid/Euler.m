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
%

% set convention
if check_option(varargin,{'Bunge','ZXZ'})
  convention = 'ZXZ';
elseif check_option(varargin,{'ABG','ZYZ'})
  convention = 'ZYZ';
else
  convention = get_flag(get(S3G,'options'),{'ZXZ','ZYZ'},'none');
end

if check_option(S3G,convention)
  
  if nargout == 3
    varargout{1} = vertcat(S3G.alphabeta(:,1));
    varargout{2} = vertcat(S3G.alphabeta(:,2));
    varargout{3} = vertcat(S3G.alphabeta(:,3));    
  else
    varargout{1} = vertcat(S3G.alphabeta);
  end
    
else
  
  [varargout{1:nargout}] = Euler(quaternion(S3G),varargin{:});
  
end
