function d = dot_outer(m1,m2,varargin)
% inner product between two Miller indece
%
% Syntax
%  a = dot_outer(m1,m2)
%
% Input
%  m1,m2 - @Miller
%
% Output
%  d - m1 . m2

if check_option(varargin,'noSymmetry')
  d = dot_outer(vector3d(m1),vector3d(m2));
  return
end

if ~isa(m1,'Miller') || ~isa(m2,'Miller') || m1.CS ~= m2.CS
  warning('Symmetry mismatch')
end

% symmetrise
m1 = symmetrise(m1,varargin{:});
s = [size(m1),length(m2)];

% normalize
m1 = m1 ./ norm(m1);
m2 = m2 ./ norm(m2);

% dotproduct
d = reshape(dot_outer(vector3d(m1),vector3d(m2)),s);

% find maximum
d = squeeze(max(d,[],1));
