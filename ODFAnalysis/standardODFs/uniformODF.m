function odf = uniformODF(varargin)

% get crystal and specimen symmetry
[CS,SS] = extractSymmetries(varargin{:});
                      
odf = SO3FunRBF(orientation(CS,SS),SO3deLaValleePoussin,[],1);

end
