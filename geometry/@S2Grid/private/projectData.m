function [X,Y,bounds] = projectData(theta,rho,varargin)

% get projection
if isappdata(gcf,'projection')  
  projection = getappdata(gcf,'projection');
else
  projection = 'earea';
end
projection = get_option(varargin,'projection',projection);


% project data
switch lower(projection)
  
  case 'plain'

    X = rho; Y = theta;
    
  case 'edist' % equal distance
  
    [X,Y] = stereographicProj(theta,rho);
    bounds = [-2, -2, 4, 4];
  
  case 'earea' % equal area
    
    [X,Y] = SchmidtProj(theta,rho);
    bounds = [-1.4142, -1.4142, 2*1.4142 , 2*1.4142];

  otherwise
    
    error('Unknown Projection!')
    
end

% store projection
setappdata(gcf,'projection',projection);

% bounding box 
if check_option(varargin,{'plain','contour','contour','smooth'})

  bounds = [min(X(:)),min(Y(:)),max(X(:))-min(X(:)),max(Y(:))-min(Y(:))];
  
end
