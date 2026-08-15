function m = mean(v,varargin)

m = mean@vector3d(v,varargin{:});

% cut the rotations
if isscalar(m)
  m.oriRef = v.oriRef(1);
else
  sm = size(m);
  d = length(size(m.oriRef));
  sm(end+1:d) = 1;
  idx = repmat({':'}, 1, d);
  for i = 1:d
    if sm(i)==1
      idx{i} = 1;
    end
  end
  m.oriRef = m.oriRef(idx{:});
end

% ensure compatible tangent spaces
ensureCompatibleTangentSpaces(v,m,'equal');

end