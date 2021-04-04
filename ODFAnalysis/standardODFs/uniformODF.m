function odf = uniformODF(varargin)

% get crystal and specimen symmetry
[CS,SS] = extractSymmetries(varargin{:});
                      
odf = SO3FunHarmonic(1,CS,SS);

end
