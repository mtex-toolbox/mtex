function p = polytope(varargin)


p.Vertices = get_option(varargin,'Vertices',[]);  % vertex ids
p.Faces = get_option(varargin,'Faces',[]);  % facet ids
p.VertexIds = [];  % the points
p.FacetIds = [];  % the mesh
p.Holes = [];
p.Envelope = [];

plg = polygon(p);
plt = polyeder(p);

if nargin > 0
  
  tp = varargin{1};
      
  if isa(tp,'polytope')
    
    return
    
  elseif isa(tp,'struct')
       
    if isfield(tp,'polygon'), tp = rmfield(tp,'polygon'); end
    if isfield(tp,'polyeder'), tp = rmfield(tp,'polyeder'); end
  
    p = tp;
    
  else
    
  end
end

p = class(p,'polytope',plg,plt);

