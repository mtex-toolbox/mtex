function d = dot(m1,m2,varargin)
% inner product between two Miller indece
%
%% Syntax
% a = dot(m1,m2)
% a = dot(m1,m2,'antipodal')
%
%% Input
%  m1,m2 - @Miller
%
%% Output
%  d - double [size(m1) numel(cs)]
% 
%% Options
%  antipodal - consider m1,m2 with antipodal symmetry
%  all       -


if numel(m1) == 1 || numel(m2) == 1
  d = dot_outer(m1,m2,varargin{:});
  
  if numel(m1) == 1
    d = reshape(d,[size(m2),size(d,3)]);
  else
    d = reshape(d,[size(m1),size(d,3)]);
  end
  return
end

% symmetrize
m1 = vector3d(symmetrise(m1,varargin{:}));
m2 = vector3d(repmat(reshape(m2,1,[]),size(m1,1),1));


% normalize
m1 = m1 ./ norm(m1);
m2 = m2 ./ norm(m2);

% dotproduct
d = dot(m1,m2);

% find maximum
if ~check_option(varargin,'all')
  d = max(d,[],1);
end
