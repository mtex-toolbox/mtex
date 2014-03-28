function surf(v,cdata,varargin)
%
% Syntax
%
% Input
%
% Output
%
% Options
%
% See also
%


% initialize spherical plot
sP = newSphericalPlot(v,varargin{:});

for j = 1:numel(sP)

  %set(gcf,'renderer','zBuffer');
  %shading interp

  % draw surface
      
  % project data
  [x,y] = project(sP(j).proj,v,'removeAntipodal');
    
  % extract non nan data
  ind = ~isnan(x);
  x = submatrix(x,ind);
  y = submatrix(y,ind);
  data = reshape(submatrix(cdata,ind),[size(x) 3]);
  
  % otherwise surf would change current axes settings
  hold(sP(j).ax,'on')
  
  % plot surface  
  h = surf(x,y,zeros(size(x)),real(data),'parent',sP(j).ax);
    
  hold(sP(j).ax,'off')
  
  % set styles
  optiondraw(h,'LineStyle','none','Fill','on',varargin{:});

end
