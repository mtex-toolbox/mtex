function d = dot_outer(v1,v2,varargin)
% outer dot product
%
% Input
%  v1, v2 - @vector3d
%
% Output
%  d - double of size length(v1) × length(v2)
%
% Options
%  antipodal - consider smallest angle, i.e., consider vectors as axes
%  ignoreAntipodal - antipodal flag in v1/v2 is ignored
%  noSymmetry - do *not* consider sym. equiv. directions of v1
%  max       - (default) maximum dot product with respect to all sym. equiv.
%  min       - minimum dot product with respect to all sym. equiv.
%

% a direction whose frame carries a group is compared through its whole
% symmetrically equivalent set, and one of the two sides carrying one is enough
if ~check_option(varargin,'noSymmetry') && (hasSymmetry(v1) || hasSymmetry(v2))

  % the symmetrised side goes first, and the outer product is transposed back
  flipped = ~hasSymmetry(v1);
  if flipped, [v1,v2] = deal(v2,v1); end

  if hasSymmetry(v2) && ~symFits(v1.frame,v2.frame,'compatible')
    warning('Symmetry mismatch')
  end

  % symmetrise
  v1 = symmetrise(v1,varargin{:});
  s = [size(v1),length(v2)];

  % dotproduct
  d = outerProduct(v1,v2);
  d = reshape(d,s);

  % find maximum angle
  if check_option(varargin,'min')
    d = reshape(min(d,[],1),s(2:3));
  else
    d = reshape(max(d,[],1),s(2:3));
  end

  if flipped, d = d.'; end
  return
end

d = outerProduct(v1,v2,varargin{:});

end

% -----------------------------------------------------------------

function d = outerProduct(v1,v2,varargin)

if ~isempty(v1) && ~isempty(v2)
  d = v1.x(:) * v2.x(:).' + v1.y(:) * v2.y(:).' + v1.z(:) * v2.z(:).';

  if (check_option(varargin,'antipodal') || v1.antipodal || v2.antipodal) ...
      && ~check_option(varargin,'noAntipodal')
    d = abs(d);
  end

else
  d  = [];
end

end
