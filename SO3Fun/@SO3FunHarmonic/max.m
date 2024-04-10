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
%   [value,ori] = max(SantaFe)
%   plotPDF(SantaFe,Miller(0,0,1,ori.CS))
%   annotate(ori)
%
% See also
% SO3Fun/min SO3Fun/max SO3Fun/calcComponents

if isa(SO3F,'SO3FunHarmonic') && ~SO3F.isReal
  SO3F = SO3F.isReal;
  warning('By taking the maxima of SO3Funs, the functions should be real valued.')
end
if nargin>1 && isa(varargin{1},'SO3FunHarmonic') && ~varargin{1}.isReal
  varargin{1}.isReal = 1;
  warning('By taking the maxima of SO3Funs, the functions should be real valued.')
end

if isscalar(SO3F)
  [values,modes] = max@SO3Fun(SO3F,varargin{:});
  return
end

% multivariate functions
s = size(SO3F);

if nargin>1 && (isa(varargin{1},'SO3FunHarmonic') || isnumeric(varargin{1}))
  t = size(varargin{1});
  SO3F1 = SO3F.*ones(t);
  SO3F2 = varargin{1}.*ones(s);
  values = [];
  for k=1:numel(SO3F1)
    if isa(SO3F2,'SO3FunHarmonic')
      A = max@SO3Fun(SO3F1.subSet(k),SO3F2.subSet(k),varargin{:});
    else
      A = max@SO3Fun(SO3F1.subSet(k),SO3F2(k),varargin{:});
    end
    values = [values,A];
  end
  values = reshape(values,size(SO3F1));
  return
end

len = get_option(varargin,'numLocal',1);
values = zeros(len,prod(s));
modes = rotation.id(len,prod(s));
for k=1:numel(SO3F)
  [v,m] = max@SO3Fun(SO3F.subSet(k),varargin{:});
  values(:,k)=v; modes(:,k)=m;
end

end