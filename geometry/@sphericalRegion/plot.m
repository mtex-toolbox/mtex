function varargout = plot(sR,varargin)
% plots a spherical region
%
% This function is called by all spherical plot methods to plot the outer
% boundary and adjust the axes limits properly.
%

% initialize spherical plots
sP = newSphericalPlot(sR,varargin{:});

for j = 1:numel(sP)
  
  % plot the region
  omega = linspace(0,2*pi,721);
  for i=1:length(sR.N)
  
    rot = rotation('axis',sR.N(i),'angle',omega);
    bigCircle = rotate(orth(sR.N(i)),rot);
    v = sR.alpha(i) * sR.N(i) + sqrt(1-sR.alpha(i)^2) * bigCircle;
    
    % project data
    [x,y] = project(sP(j).proj,v);
    
    % plot
    h(i) = line('xdata',x,'ydata',y,'parent',sP(j).ax,...
      'color',[0.2 0.2 0.2],'linewidth',1.5); %#ok<AGROW>
  end
end

% give handles back
if nargout > 0, varargout{1} = h; end

end
