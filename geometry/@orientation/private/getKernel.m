function psi = getKernel(ori,varargin)
    
% get halfwidth and kernel
if check_option(varargin,'kernel')
  psi = get_option(varargin,'kernel');
elseif check_option(varargin,'halfwidth','double')
  psi = deLaValeePoussinKernel(varargin{:});
else
  
  if ~check_option(varargin,'spatialDependent')
    kappa = (length(ori.CS) * length(ori.SS) * length(ori))^(2/7) * 3; % magic rule
    psi = deLaValeePoussinKernel(kappa,varargin{:});
  else
    psi = deLaValeePoussinKernel('halfwidth',10*degree,varargin{:});
  end
  
end

end
