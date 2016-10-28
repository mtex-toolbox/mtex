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
if check_option(varargin,'noSymmetry')
  d = dot(vector3d(m1),vector3d(m2),varargin{:});
  return
end

% if we should consider symmetry - it must be the same on both sides
if ~isa(m1,'Miller') || ~isa(m2,'Miller') || m1.CS ~= m2.CS
  warning('Symmetry mismatch')
end

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
m1 = vector3d(symmetrise(m1,varargin{:}));
m2 = vector3d(repmat(reshape(m2,1,[]),size(m1,1),1));

% normalize
m1 = m1 ./ norm(m1);
m2 = m2 ./ norm(m2);

% dotproduct
d = dot(m1,m2);

% find maximum
if ~check_option(varargin,'all')
  d = reshape(max(d,[],1),s);  
end
