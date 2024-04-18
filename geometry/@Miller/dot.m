function d = dot(m1,m2,varargin)
% inner product between two Miller indece
%
% Syntax
%   d = dot(m1,m2)
%   d = dot(m1,m2,'antipodal')
%
% Input
%  m1, m2 - @Miller
%
% Output
%  d - double, same size as |m1| and |m2| 
% 
% Options
%  noSymmetry - do *not* consider sym. equiv. directions
%  max       - (default) maximum dot product with respect to all sym. equiv.
%  min       - minimum dot product with respect to all sym. equiv.
%  all       - all dot products with respect to sym. equiv.
%  antipodal - include antipodal symmetry
%

% maybe we should ignore symmetry
if check_option(varargin,'noSymmetry') || ~isa(m2,'Miller')
  d = dot@vector3d(m1,m2,varargin{:});
  return
end

% if we should consider symmetry - it must be the same on both sides
if m1.CS.Laue  ~= m2.CS.Laue, warning('Symmetry mismatch'); end

% maybe we should return a full matrix of dot products to all symmetrically
% equivalent directions
if check_option(varargin,'all')

  if isscalar(m1)
    m1 = repmat(m1,size(m2));
  else
    m2 = repmat(m2,size(m1));
  end

elseif (isscalar(m1) || isscalar(m2)) % use dot_outer whenever possible
  d = dot_outer(m1,m2,varargin{:});
  
  if isscalar(m1)
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

% which angle to return
if check_option(varargin,'min')
  d = reshape(min(d,[],1),s); % minimum angle of all symmetricaly equ.
elseif ~check_option(varargin,'all')
  d = reshape(max(d,[],1),s); % maximum angle of all symmetricaly equ.
end
