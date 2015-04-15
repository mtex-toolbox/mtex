function varargout = plot(sR,varargin)
% plots a spherical region
%
% This function is called by all spherical plot methods to plot the outer
% boundary and adjust the axes limits properly.
%

% initialize spherical plots
sP = newSphericalPlot(sR,varargin{:});

for j = 1:numel(sP)
  
  % ensure sector is at this hemisphere TODO
  %if any(any(dot_outer(sR.N,sP(j).sphericalRegion.N)<eps-1)), continue, end
 
  %if all(sR.checkInside(sP(j).sphericalRegion.N)) && ~isempty(sP(j).boundary)
  if ~isempty(sP(j).boundary) && sR == sP(j).sphericalRegion
    h = optiondraw(sP(j).boundary,varargin{:});
    continue; 
  end
  
  % plot the region
  omega = linspace(0,2*pi,721);
  for i=1:length(sR.N)
  
    rot = rotation('axis',sR.N(i),'angle',omega);
    bigCircle = rotate(orth(sR.N(i)),rot);
    v = sR.alpha(i) * sR.N(i) + sqrt(1-sR.alpha(i)^2) * bigCircle;
    
    % project data
    [x,y] = project(sP(j).proj,v);
    x(~sR.checkInside(v))=NaN;
                
    % plot
    h(i) = optiondraw(line('xdata',x,'ydata',y,'parent',sP(j).ax,...
      'color',[0.2 0.2 0.2],'linewidth',1.5,'hitTest','off'),varargin{:});
    
    % do not display in the legend
    set(get(get(h(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

  end
end

% give handles back
if nargout > 0, varargout{1} = h; end

end
