function odf = uniformODF(varargin)

% get crystal and specimen symmetry
[CS,SS] = extractSym(varargin);
                      
odf = SO3FunRBF(orientation(CS,SS),SO3deLaValleePoussinKernel,[],1);

end
