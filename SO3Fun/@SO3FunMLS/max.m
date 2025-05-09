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

if nargin==1
  [values,ind] = max(SO3F.values);
  modes = SO3F.nodes(ind);
  return
end

if isa(SO3F,'SO3FunMLS') && isa(varargin{1},'SO3FunMLS') && ...
    length(SO3F.nodes) == length(varargin{1}.nodes) && ...
    all(SO3F.nodes(:) == varargin{1}.nodes(:))
  SO3F.values = max(SO3F.values,varargin{1}.values);
  return
end

[values,modes] = max@SO3Fun(SO3F,varargin{:});

end

