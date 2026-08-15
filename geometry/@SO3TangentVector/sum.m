function s = sum(v,varargin)
% overload sum

s = sum@vector3d(v,varargin{:});

% cut the rotations
if isscalar(s)
  s.oriRef = v.oriRef(1);
else
  sm = size(s);
  d = length(size(s.oriRef));
  sm(end+1:d) = 1;
  idx = repmat({':'}, 1, d);
  for i = 1:d
    if sm(i)==1
      idx{i} = 1;
    end
  end
  s.oriRef = s.oriRef(idx{:});
end

% ensure compatible tangent spaces
ensureCompatibleTangentSpaces(v,s,'equal');

end