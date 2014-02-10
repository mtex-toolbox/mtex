function [S3G, options]= extract_SO3grid(obj,varargin)

if nargin == 2, 
  varargin = varargin{:}; 
  if ~iscell(varargin)
    varargin = {varargin};
  end
end

% discretisation
S3G = get_option(varargin,'SO3Grid',[],'SO3Grid');
if isempty(S3G), %eval when necessary
  res = get_option(varargin,'RESOLUTION',2.5*degree);
  S3G = equispacedSO3Grid(obj.CS,obj.SS,'resolution',res); 
end

if nargout > 1, options = set_option(varargin,'SO3Grid',S3G); end
