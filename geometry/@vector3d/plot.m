function plot(v,varargin)
% plot three dimensional vector
%
%
%% Options
%  Marker          
%  MarkerSize
%  MarkerFaceColor
%  MarkerEdgeColor

if check_option(varargin,'labeled')
  s = cell(1,numel(v));
  for i = 1:numel(v), s{i} = subsref(v,i); end
  varargin = {'MarkerEdgeColor','w','MarkerFaceColor','k','Marker','s','label',s,varargin{:}};
  c = colormap;
  if ~all(equal(c,2)), varargin = {'BackGroundColor','w',varargin{:}};end
end
  
plot(S2Grid(v),'grid',v.options{:},varargin{:});
