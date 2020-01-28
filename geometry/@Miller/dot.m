function d = dot(m1,m2,varargin)
% inner product between two Miller indece
%
% Syntax
%   a = dot(m1,m2)
%   a = dot(m1,m2,'antipodal')
%
% Input
%  m1,m2 - @Miller
%
% Output
%  d - double [length(m1) length(cs)]
% 
% Options
%  antipodal - consider m1,m2 with antipodal symmetry
%  all       -

% maybe we should ignore symmetry
if check_option(varargin,'noSymmetry') || ~isa(m2,'Miller')
  d = dot@vector3d(m1,m2,varargin{:});
  return
end

% if we should consider symmetry - it must be the same on both sides
if ~eq(m1.CS,m2.CS), warning('Symmetry mismatch'); end

% maybe we should return a full matrix of dot products to all symmetrically
% equivalent directions
if check_option(varargin,'all')

  if length(m1) == 1
    m1 = repmat(m1,size(m2));
  else
    m2 = repmat(m2,size(m1));
  end

elseif (length(m1)==1 || length(m2) == 1) % use dot_outer whenever possible
  d = dot_outer(m1,m2,varargin{:});
  
  if length(m1) == 1
    d = reshape(d,[size(m2),size(d,3)]);
  else
    d = reshape(d,[size(m1),size(d,3)]);
  end
  return
end

% symmetrize
s = size(m1);
m1 = symmetrise(m1,varargin{:});
m2 = repmat(reshape(m2,1,[]),size(m1,1),1);

% vector3d dot product
d = dot@vector3d(m1,m2,varargin{:});

% find maximum
if ~check_option(varargin,'all'), d = reshape(max(d,[],1),s); end
