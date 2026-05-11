function m = mean(v,varargin)

m = mean@vector3d(v,varargin{:});

% cut the rotations
if isscalar(m)
  m.rot = v.rot(1);
else
  sm = size(m);
  d = length(size(m.rot));
  sm(end+1:d) = 1;
  idx = repmat({':'}, 1, d);
  for i = 1:d
    if sm(i)==1
      idx{i} = 1;
    end
  end
  m.rot = m.rot(idx{:});
end

% ensure compatible tangent spaces
ensureCompatibleTangentSpaces(v,m,'equal');

end