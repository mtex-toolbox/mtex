function s = sum(v,varargin)
% overload sum

s = sum@vector3d(v,varargin{:});

% cut the rotations
if isscalar(s)
  s.rot = v.rot(1);
else
  sm = size(s);
  d = length(size(s.rot));
  sm(end+1:d) = 1;
  idx = repmat({':'}, 1, d);
  for i = 1:d
    if sm(i)==1
      idx{i} = 1;
    end
  end
  s.rot = s.rot(idx{:});
end

% ensure compatible tangent spaces
ensureCompatibleTangentSpaces(v,s,'equal');

end