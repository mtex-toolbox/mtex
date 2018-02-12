function varargout = max(varargin)
% global, local and pointwise maxima of spherical functions
%
% Syntax
%   [v,pos] = max(sF) % the position where the maximum is atained
%
%   [v,pos] = max(sF,'numLocal',5) % the 5 largest local maxima
%
%   sF = max(sF, c) % maximum of a spherical functions and a constant
%   sF = max(sF1, sF2) % maximum of two spherical functions
%   sF = max(sF1, sF2, 'bandwidth', bw) % specify the new bandwidth
%
%   % compute the maximum of a multivariate function along dim
%   sF = max(sFmulti,[],dim)
%
% Input
%  sF, sF1, sF2 - @S2Fun
%  sFmulti - a multivariate @S2Fun
%  c       - double
%
% Output
%  v - double
%  pos - @vector3d
%
% Options
%  kmax - number of iterations
%  numLocal      - number of peaks to return
%  startingNodes - @vector3d
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size
%

varargin{1} = -varargin{1};
if nargin>1 && ( ~isempty(varargin{2}) && isa(varargin{2},'double') || isa(varargin{2},'S2Fun' ))
  varargin{2} = -varargin{2};
end

[varargout{1:nargout}] = min(varargin{:});

varargout{1} = - varargout{1};

end
