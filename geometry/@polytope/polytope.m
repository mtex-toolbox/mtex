function p = polytope(varargin)
% constructor of the class polytope

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
  
  if isa(tp,'polygon') || isa(tp,'polyeder')
    
    p = struct(tp);
    
  elseif isa(tp,'polytope')
    
    return
    
  elseif isa(tp,'struct')
    
    p = tp;
    
  else
    
  end
  
  if isfield(p,'polygon'), p = rmfield(p,'polygon'); end
  if isfield(p,'polyeder'), p = rmfield(p,'polyeder'); end
  
end

p = class(p,'polytope',plg,plt);

