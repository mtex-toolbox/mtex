function [X,Y] = project(v,projection,extend,varargin)
% perform spherical projection and restriction to plotable domain

%% for antipodal symmetry project all to current hemisphere
if projection.antipodal && ~check_option(varargin,'removeAntipodal')
  
  if ~(isnumeric(extend.maxTheta) && extend.maxTheta == pi) 
    v = subsasgn(v,v.z < -1e-6,-vector3d(subsref(v,v.z < -1e-6)));
  elseif isappr(extend.minTheta,pi/2)
    v = subsasgn(v,v.z > 1e-6,-vector3d(subsref(v,v.z > 1e-6)));
  end  
end

% compute polar angles
[theta,rho] = polar(v);


%% restrict to plotable domain

% check for azimuth angle
if extend.maxRho - extend.minRho < 2*pi-1e-6  
  inRho = rhoInside(rho,extend.minRho,extend.maxRho) | isnull(sin(theta));  
  rho(~inRho) = NaN;
end

% check for polar angle
if isa(extend.maxTheta,'function_handle')
  theta(theta-1e-6 > extend.maxTheta(rho)) = NaN;
else
  theta(theta-1e-6 > extend.maxTheta) = NaN;
  theta(theta+1e-6 < extend.minTheta) = NaN;
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

% format output
X = reshape(X,size(v));
Y = reshape(Y,size(v));

