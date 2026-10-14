function [h,ax] = surf(v,cdata,varargin)
% plot RGB colour data on a grid of directions as a surface in a spherical projection
%
% Syntax
%
%   h = surf(v,cdata) % colour the grid v by cdata
%
% Input
%  v     - @vector3d, a grid of directions
%  cdata - RGB data, of the size of v by 3
%
% Output
%  h - handle to the graphics objects
%

% initialize spherical plot
sP = newSphericalPlot(v,varargin{:},'doNotDraw');

for j = 1:numel(sP)

  % project data
  [x,y] = sP(j).proj.project(v,'noAntipodal');
    
  % extract non nan data
  ind = ~isnan(x);
  cdata = reshape(cdata,size(x,1),size(x,2),[]);
  x = submatrix(x,ind);
  y = submatrix(y,ind);
  data = reshape(submatrix(cdata,ind),[size(x) 3]);
  
  % otherwise surf would change current axes settings
  hG = holdOn(sP(j).ax); %#ok<NASGU>

  % plot surface  
  h(j) = surf(x,y,zeros(size(x)),real(data),'parent',sP(j).ax,...
    'edgeColor','none'); %#ok<AGROW>

  clear hG
  
  % set styles
  varargin = delete_option(varargin,'parent',1);
  optiondraw(h(j),'LineStyle','none','Fill','on',varargin{:});
  
  % bring grid in front
  sP(j).doGridInFront;
end

if nargout == 0, clear h; else, ax = [sP.ax]; end
