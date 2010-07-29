function p = polytope(varargin)


% if nargin == 0

p.Vertices = get_option(varargin,'Vertices',[]);  % vertex ids
p.Faces = get_option(varargin,'Faces',[]);  % facet ids
p.VertexIds = [];  % the points
p.FacetIds = [];  % the mesh
p.Holes = [];
p.Envelope = [];

plg = polygon(p);
plt = polyeder(p);

if nargin > 0
  
  p = varargin{1};
      
  if isa(p,'polytope')
    
    return
    
  elseif isa(p,'struct')
       
    if isfield(p,'polygon'), p = rmfield(p,'polygon'); end
    if isfield(p,'polyeder'), p = rmfield(p,'polyeder'); end
   
  end
end

p = class(p,'polytope',plg,plt);

