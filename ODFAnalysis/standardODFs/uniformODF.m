function odf = uniformODF(varargin)

% get crystal and specimen symmetry
[CS,SS] = extractSym(varargin);
                      
odf = SO3FunRBF(orientation(CS,SS),SO3DeLaValleePoussinKernel,[],1);

end
