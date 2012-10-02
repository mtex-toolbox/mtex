function [X,Y] = project(v,projection,varargin)
% perform spherical projection and restriction to plotable domain


% determine which points are on the southern hemisphere
if check_option(varargin,'equator2south')
  eps = 1e-6;
else
  eps = -1e-6;
end
south = v.z < eps;


% for antipodal symmetry project all to northern hemisphere
if projection.antipodal && ~(isnumeric(projection.maxTheta) && projection.maxTheta == pi)
  v = subsasgn(v,south,-vector3d(subsref(v,south)));
  south = false(size(v));
end

% compute polar angles
[theta,rho] = polar(v);


%% restrict to plotable domain

% check for azimuth angle
if projection.maxRho - projection.minRho < 2*pi-1e-6  
  inRho = inside(rho,projection.minRho,projection.maxRho) | isnull(sin(theta));  
  rho(~inRho) = NaN;
end

% check for polar angle
if isa(projection.maxTheta,'function_handle')
  theta(theta-1e-6 > projection.maxTheta(rho)) = NaN;
else
  theta(theta-1e-6 > projection.maxTheta) = NaN;
  theta(theta+1e-6 < projection.minTheta) = NaN;
end


%% compute spherical projection
switch lower(projection.type)
  
  case 'plain'
    %     X = rho;
    
    if isa(v,'S2Grid'),  X = rho;
    else   X = mod(rho,2*pi);  end    
    Y = theta;
    %     axis ij;
    
  case {'stereo','eangle'} % equal angle
    
    [X,Y] = stereographicProj(theta,rho);
    
  case 'edist' % equal distance
    
    [X,Y] = edistProj(theta,rho);
    
  case {'earea','schmidt'} % equal area
    
    [X,Y] = SchmidtProj(theta,rho);
    
  case 'orthographic'
    
    [X,Y] = orthographicProj(theta,rho);
    
  otherwise
    
    error('Unknown Projection!')
    
end

%% points on the southern hemisphere should be shifted to the left / right
if projection.minTheta == 0 && ~strcmp(projection.type,'plain')
  if strcmp(projection.zAxis,'outOfPlane')
    X(south) = X(south) + projection.offset;
  else
    X(~south) = X(~south) + projection.offset;
  end
end
  
% format output
X = reshape(X,size(v));
Y = reshape(Y,size(v));


function ind = inside(rho,minRho,maxRho)

minr = mod(minRho+1e-6,2*pi)-3e-6;
maxr = mod(maxRho-1e-6,2*pi)+3e-6;
if minr < maxr
  ind = mod(rho-1e-6,2*pi) > minr & mod(rho+1e-6,2*pi) < maxr;
else
  ind = ~(mod(rho+1e-6,2*pi) > maxr & mod(rho-1e-6,2*pi) < minr);
end

% inside mean, there is a value of k such that 
