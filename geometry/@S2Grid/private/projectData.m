function [X,Y,bounds] = projectData(theta,rho,varargin)

% projection
if check_option(varargin,'PLAIN')

  X = rho; Y = theta; 
    
elseif check_option(varargin,'EDIST') % equal distance
  
  [X,Y] = stereographicProj(theta,rho);
  bounds = [-2, -2, 4, 4];
  
else % equal area
  
  [X,Y] = SchmidtProj(theta,rho);
  bounds = [-1.4142, -1.4142, 2*1.4142 , 2*1.4142];
  
end

% bounding box 
if check_option(varargin,{'plain','contour','contour','smooth'})

  bounds = [min(X(:)),min(Y(:)),max(X(:))-min(X(:)),max(Y(:))-min(Y(:))];
  
end
