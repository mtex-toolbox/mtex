function plot(v,varargin)
% plot three dimensional vector
%
%
%% Options
%  Marker          
%  MarkerSize
%  MarkerFaceColor
%  MarkerEdgeColor
%
%% Flags
%  smooth   - plot point cloud as colored density
%  contourf - plot point cloud as filled contours
%  contour  - plot point cloud as contours


if check_option(varargin,{'smooth','contourf','contour'})
  o = extract_option(v.options,'antipodal');
  x = S2Grid('plot',o{:},varargin{:});
  kde = kernelDensityEstimation(v,x,o{:},varargin{:});
  plot(x,'data',kde,varargin{:});
  return
end


if check_option(varargin,'labeled')
  s = cell(1,numel(v));
  for i = 1:numel(v), s{i} = subsref(v,i); end
  varargin = {'MarkerEdgeColor','w','MarkerFaceColor','k','Marker','s','label',s,varargin{:}};
  c = colormap;
  if ~all(equal(c,2)), varargin = {'BackGroundColor','w',varargin{:}};end
end
  
plot(S2Grid(v),'grid',v.options{:},varargin{:});
