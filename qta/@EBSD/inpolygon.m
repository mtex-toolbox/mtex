function ebsd = inpolygon(ebsd,varargin)
% select ebsd data by a given polygon
%
%% Syntax
% ebsd = inpolygon(ebsd,polygon)
% ebsd = inpolygon(ebsd,[x1 y1; x2 y2; x3 y3; x4 y4])
%
%% Input
%  ebsd    - @EBSD
%  polygon - @polygon
%  x1, y1  - vertices
%
%% Ouput
%  ebsd - @EBSD
%
%% See also
% grain/inpolygon polygon/inpolygon

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

  % remove data not inside the polygons
  ebsd = delete(ebsd,~ind);
end
