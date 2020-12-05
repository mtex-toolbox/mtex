function ebsd = reshape(ebsd,varargin)
% reshape

ebsd.rotations = reshape(ebsd.rotations,varargin{:});
ebsd.id = reshape(ebsd.id,varargin{:});


for fn = fieldnames(ebsd.prop).'
        
  ebsd.prop.(char(fn)) = reshape(ebsd.prop.(char(fn)),varargin{:});
        
end


end