function varargout = max(SO3F,varargin)
% global, local and pointwise maxima of functions on SO(3)
%
% Syntax
%   [v,pos] = max(SO3F) % the largest node value and its node
%
%   [v,pos] = max(SO3F,'numLocal',5) % the 5 largest local maxima
%
%   SO3F = max(SO3F, c) % maximum of a rotational functions and a constant
%   SO3F = max(SO3F1, SO3F2) % maximum of two rotational functions,
%                            % of the node values for the same nodes
%
%   % compute the maximum of a multivariate function along dim
%   SO3F = max(SO3Fmulti,[],dim)
%
% Input
%  SO3F, SO3F1, SO3F2 - @SO3Fun
%  SO3Fmulti          - a multivariate @SO3Fun
%  c                  - double
%
% Output
%  v - double
%  pos - @rotation / @orientation
%
% Options
%  kmax          - number of iterations
%  numLocal      - number of peaks to return
%  startingNodes - @rotation / @orientation
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximum step size
%
% Example
%
%   %find the local maxima of the <SantaFe.html SantaFe> ODF
%   [value,ori] = max(SantaFe)
%   plotPDF(SantaFe,Miller(0,0,1,ori.CS))
%   annotate(ori)
%
% See also
% SO3Fun/min SO3Fun/max SO3Fun/calcComponents

if nargin == 1
  [varargout{1},ind] = max(SO3F.values);
  varargout{2} = SO3F.nodes(ind);
  return
end

% the node values of the same nodes
if isa(varargin{1},'SO3FunMLS')
  [varargout{1},done] = valueOp(SO3F,varargin{1},@max);
  if done, return; end
end

[varargout{1:max(nargout,1)}] = max@SO3Fun(SO3F,varargin{:});

end
