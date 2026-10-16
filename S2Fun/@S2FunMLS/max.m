function varargout = max(S2F,varargin)
% global, local and pointwise maxima of an S2FunMLS
%
% Syntax
%   [v,pos] = max(S2F)       % the largest node value and its node
%   S2F = max(S2F1,S2F2)     % maximum of the node values of the same nodes
%   [v,pos] = max(S2F,'numLocal',5) % local maxima, see S2Fun/max
%
% Input
%  S2F, S2F1, S2F2 - @S2FunMLS
%
% Output
%  v   - double
%  pos - @vector3d
%
% See also
% S2Fun/max S2Fun/min

if nargin == 1
  [varargout{1},ind] = max(S2F.values);
  varargout{2} = S2F.nodes(ind);
  return
end

if isa(varargin{1},'S2FunMLS')
  [varargout{1},done] = valueOp(S2F,varargin{1},@max);
  if done, return; end
end

[varargout{1:max(nargout,1)}] = max@S2Fun(S2F,varargin{:});

end
