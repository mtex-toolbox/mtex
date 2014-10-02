function odf = uniformODF(varargin)


% get crystal and specimen symmetry
[CS,SS] = extractSymmetries(varargin{:});
                      
component = uniformComponent(CS,SS);

odf = ODF(component,1);

end
