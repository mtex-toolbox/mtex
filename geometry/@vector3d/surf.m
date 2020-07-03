function [h,ax] = surf(v,cdata,varargin)
%
% Syntax
%   h = surf(v,cdata)
%
% Input
%  c     - @vector3d
%  cdata - RGB data
%
% Output
%
% Options
%
% See also
%

% initialize spherical plot
sP = newSphericalPlot(v,varargin{:},'doNotDraw');

for j = 1:numel(sP)

  % project data
  [x,y] = project(sP(j).proj,v,'noAntipodal');
    
  % extract non nan data
  ind = ~isnan(x);
  cdata = reshape(cdata,size(x,1),size(x,2),[]);
  x = submatrix(x,ind);
  y = submatrix(y,ind);
  data = reshape(submatrix(cdata,ind),[size(x) 3]);
  
  % otherwise surf would change current axes settings
  hold(sP(j).ax,'on')
  
  % plot surface  
  h(j) = surf(x,y,zeros(size(x)),real(data),'parent',sP(j).hgt,...
    'edgeColor','none'); %#ok<AGROW>
      
  hold(sP(j).ax,'off')
  
  % set styles
  varargin = delete_option(varargin,'parent',1);
  optiondraw(h(j),'LineStyle','none','Fill','on',varargin{:});
  
  % bring grid in front
  sP(j).doGridInFront;
end

if nargout == 0, clear h; else, ax = [sP.ax]; end
