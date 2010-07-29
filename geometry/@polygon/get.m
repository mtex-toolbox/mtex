function s = get(p,vname,varargin)
% get some polygon properties

switch lower(vname)
  case 'vertices'
    if check_option(varargin,'cell')
      s = {p.Vertices};
      return
    elseif check_option(varargin,'plot')
      lVertices = cell(numel(p)*2,1);
      lVertices(1:2:end) = {p.Vertices};
      lVertices(2:2:end) = {[NaN NaN]};  
    else
      lVertices = {p.Vertices};
    end

    parts = [0:1000:length(lVertices)-1 length(lVertices)];    
    s = cell(numel(parts)-1,1);
    for k=1:numel(parts)-1 % faster as at once      
      s{k} = vertcat(lVertices{parts(k)+1:parts(k+1)});
    end
    s = vertcat(s{:});
    
  case {'holes'}    
    s = polygon(horzcat(p(hashole(p)).Holes));
  case {'vertexids'}
    s = {p.VertexIds};
  otherwise
    s = vertcat(p.(vname));
end
