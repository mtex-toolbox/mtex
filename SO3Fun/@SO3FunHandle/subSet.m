function SO3F = subSet(SO3F,varargin)
% subindex SO3FunRBF

SO3F.fun = @(rot) subIndexing(SO3F,rot,varargin{:});

end

function v = subIndexing(SO3F,rot,varargin)
  v = SO3F.eval(rot);
  v = v(:,varargin{:});
end

