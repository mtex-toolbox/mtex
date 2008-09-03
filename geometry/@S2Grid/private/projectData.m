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

    X = rho; Y = fliplr(theta);
    
  case {'stereo','eangle'} % equal angle
  
    [X,Y] = stereographicProj(theta,rho);
    bounds = [-2, -2, 4, 4];
    
  case 'edist' % equal distance
  
    [X,Y] = edistProj(theta,rho);
    bounds = [-pi/2, -pi/2, pi, pi];
  
  case {'earea','schmidt'} % equal area
    
    [X,Y] = SchmidtProj(theta,rho);
    bounds = [-1.4142, -1.4142, 2*1.4142 , 2*1.4142];

  case 'orthographic'
    [X,Y] = orthographicProj(theta,rho);
    bounds = [-1, -1, 2 , 2];
  otherwise
    
    error('Unknown Projection!')
    
end

% store projection
setappdata(gcf,'projection',projection);

% bounding box 
if check_option(varargin,{'plain','contour','contour','smooth'})

  bounds = [min(X(:)),min(Y(:)),max(X(:))-min(X(:)),max(Y(:))-min(Y(:))];
  
end
