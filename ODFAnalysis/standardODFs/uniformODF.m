function odf = uniformODF(varargin)

v = 1;
if nargin>0 && isnumeric(varargin{1}) && length(varargin{1})==1
  v = varargin{1};
end

% get crystal and specimen symmetry
[CS,SS] = extractSym(varargin);
                      
odf = SO3FunRBF(orientation(CS,SS),SO3DeLaValleePoussinKernel,[],v);

end
