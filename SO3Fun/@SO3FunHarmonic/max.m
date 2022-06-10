function [values,modes] = max(SO3F,varargin)
% global, local and pointwise maxima of functions on SO(3)
%
% Syntax
%   [v,pos] = max(SO3F) % the position where the maximum is atained
%
%   [v,pos] = max(SO3F,'numLocal',5) % the 5 largest local maxima
%
%   SO3F = max(SO3F, c) % maximum of a rotational functions and a constant
%   SO3F = max(SO3F1, SO3F2) % maximum of two rotational functions
%   SO3F = max(SO3F1, SO3F2, 'bandwidth', bw) % specify the new bandwidth
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
%  maxStepSize   - maximm step size
%
% Example
%
%   %find the local maxima of the <SantaFe.html SantaFe> ODF
%   mode = calcModes(SantaFe)
%   plotPDF(SantaFe,Miller(0,0,1,mode.CS))
%   annotate(mode)
%
% See also
% SO3Fun/min SO3Fun/max

if ~SO3F.isReal || (nargin>1 && isa(varargin{1},'SO3FunHarmonic') && ~varargin{1}.isReal )
  warning('By taking the minima of SO3Funs, the functions should be real valued.')
end

s = size(SO3F);

values=zeros(s);
modes=rotation.id(s);
for k=1:numel(SO3F)
  [v,m] = max@SO3Fun(SO3F.subSet(k),varargin{:});
  values(k)=v; modes(k)=m;
end

values = reshape(values,s);
modes = reshape(modes,s);

end