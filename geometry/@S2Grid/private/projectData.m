function [X,Y,bounds] = projectData(theta,rho,varargin)


%% get projection
if isappdata(gcf,'projection')  
  projection = getappdata(gcf,'projection');
else
  projection = 'earea';
end
projection = get_option(varargin,'projection',projection);


%% modify polar coordinates

if ~strcmpi(projection,'plain')
  rho = rho + appDataOption(varargin,'rotate',0);
end
if appDataOption(varargin,'flipud',false), rho = 2*pi-rho; end
if appDataOption(varargin,'fliplr',false), rho = pi-rho; end


%% project data
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
    %bounds = [-1.42, -1.42, 2*1.42 , 2*1.42];

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

function v = appDataOption(options,token,default)

if isappdata(gcf,token)
  v = getappdata(gcf,token);
else
  if islogical(default)
    v = check_option(options,token);
  else
    v = get_option(options,token,default);
  end
  setappdata(gcf,token,v);
end