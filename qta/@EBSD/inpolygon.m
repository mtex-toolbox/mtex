function ind = inpolygon(ebsd,varargin)
% checks which ebsd data are within given polygon
%
%% Syntax
% ind = inpolygon(ebsd,polygon) - cuts EBSD data to a @polygon region
% ind = inpolygon(ebsd,[x1 y1; x2 y2; x3 y3; x4 y4]) - 
%
%% Input
%  ebsd    - @EBSD
%  polygon - @polygon
%  x1, y1  - vertices
%
%% Ouput
%  ind - logical
%
%% See also
% polygon/inpolygon

% get xy coordinates
XY = get(ebsd,'xy');

if ~isempty(XY)
  
  % generate a polygon from the input
  p = polygon(varargin{:});
  
  % init indexing
  ind = false(size(XY,1),1);
  
  % loop over all polygons and check for inside
  for k=1:numel(p)
    xy = get(p(k),'vertices');
    ind = ind | inpolygon(XY(:,1),XY(:,2),xy(:,1),xy(:,2));
  end
  
end
