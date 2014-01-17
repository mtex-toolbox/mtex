function k = getKernel(ori,varargin)
    
% get halfwidth and kernel
if check_option(varargin,'kernel')
  k = get_option(varargin,'kernel');
elseif check_option(varargin,'halfwidth','double')
  k = kernel('de la Vallee Poussin',varargin{:});
else
  
  if ~check_option(varargin,'spatialDependent')
    kappa = (length(ori.CS) * length(ori.SS) * length(ori))^(2/7) * 3; % magic rule
    k = kernel('de la Vallee Poussin',kappa,varargin{:});
  else
    k = kernel('de la Vallee Poussin','halfwidth',10*degree,varargin{:});
  end
  
end
end
