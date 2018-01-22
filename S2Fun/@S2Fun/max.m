function varargout = max(varargin)
% global or local maximum of one; or the pointwise maximum of two spherical
% functions
%
% Syntax
%   v = max(sF)       % the global maximum of a spherical function
%   [v,pos] = max(sF) % the position where the maximum(s) is(are) atained
%
%   [v,pos] = max(sF,'numLocal',5) % the 5 largest local maxima
%
%   sF = max(sF, c) % maximum of a spherical functions and a constant
%   sF = max(sF1, sF2) % maximum of two spherical functions
%
%   sF = max(sFmulti,[],dim) % compute the maximum of a multivariate function along dim
%
% Input
%  sF, sF1, sF2 - @S2Fun
%  sFmulti - a multivariate @S2Fun
%  c       - double
%
% Output
%  v - double
%  pos - @vector3d
%  sF - @S2Fun
%

varargin{1} = -varargin{1};
if nargin>1 && ( ~isempty(varargin{2}) && isa(varargin{2},'double') || isa(varargin{2},'S2Fun' ))
  varargin{2} = -varargin{2};
end

[varargout{1:nargout}] = min(varargin{:});

varargout{1} = - varargout{1};

end
