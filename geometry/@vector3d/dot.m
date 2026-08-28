function d = dot(v1,v2,varargin)
% pointwise inner product
%
% Syntax
%   d = dot(v1,v2)
%   d = dot(v1,v2,'antipodal')
%   d = dot(m1,m2,'noSymmetry')
%
% Input
%  v1, v2 - @vector3d
%
% Options
%  antipodal       - consider v1, v2 as axes
%  ignoreAntipodal - do not consider axes
%  noSymmetry      - do *not* consider sym. equiv. directions
%  max             - (default) maximum dot product with respect to all sym. equiv.
%  min             - minimum dot product with respect to all sym. equiv.
%  all             - all dot products with respect to sym. equiv.
%
% Output
%  d - double

% a direction whose frame carries a group stands for its whole symmetrically
% equivalent set, and one of the two sides carrying one is enough
if ~check_option(varargin,'noSymmetry') && (hasSymmetry(v1) || hasSymmetry(v2))

  % the product is symmetric, so the symmetrised side goes first
  if ~hasSymmetry(v1), [v1,v2] = deal(v2,v1); end

  % where both carry a group the frames must fit, see symFits
  if hasSymmetry(v2) && ~symFits(v1.frame,v2.frame,'compatible')
    warning('Symmetry mismatch');
  end

  % maybe we should return a full matrix of dot products to all
  % symmetrically equivalent directions
  if check_option(varargin,'all')

    if isscalar(v1)
      v1 = repmat(v1,size(v2));
    else
      v2 = repmat(v2,size(v1));
    end

  elseif (isscalar(v1) || isscalar(v2)) % use dot_outer whenever possible
    d = dot_outer(v1,v2,varargin{:});

    if isscalar(v1)
      d = reshape(d,[size(v2),size(d,3)]);
    else
      d = reshape(d,[size(v1),size(d,3)]);
    end
    return
  end

  % symmetrize
  s = size(v1);
  v1 = symmetrise(v1,varargin{:});
  v2 = repmat(reshape(v2,1,[]),size(v1,1),1);

  d = pointwiseDot(v1,v2,varargin{:});

  % which angle to return
  if check_option(varargin,'min')
    d = reshape(min(d,[],1),s); % minimum angle of all symmetricaly equ.
  elseif ~check_option(varargin,'all')
    d = reshape(max(d,[],1),s); % maximum angle of all symmetricaly equ.
  end
  return
end

d = pointwiseDot(v1,v2,varargin{:});

end

% -----------------------------------------------------------------

function d = pointwiseDot(v1,v2,varargin)

% compute dot product
xx = v1.x .* v2.x;
yy = v1.y .* v2.y;
zz = v1.z .* v2.z;
d = xx + yy + zz;

%
if (check_option(varargin,'antipodal') || v1.antipodal || v2.antipodal) && ...
    ~check_option(varargin,'noAntipodal')
  d = abs(d);
end

end
