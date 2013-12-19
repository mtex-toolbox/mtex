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
  inRho = rhoInside(rho,extend.minRho,extend.maxRho) | ...
    (isnull(sin(theta)) & ~strcmp(projection.type,'plain'));    
  rho(~inRho) = NaN;
end

% check for polar angle
if isa(extend.maxTheta,'function_handle')
  theta(theta-1e-6 > extend.maxTheta(rho)) = NaN;
else
  theta(theta-1e-6 > extend.maxTheta) = NaN;
  theta(theta+1e-6 < extend.minTheta) = NaN;
end


%% plain projection
if strcmpi(projection.type,'plain')
  
  if isa(v,'S2Grid')
    X = rho;
  else
    X = mod(rho,2*pi);
  end
  X = reshape(X,size(v))./ degree;
  Y = reshape(theta,size(v))./ degree;
   
  return
end

%% compute spherical projection

% map to northern hemisphere
ind = find(theta > pi/2+10^(-10));
theta(ind)  = pi - theta(ind);

% compute radius
switch lower(projection.type)
  
  case {'stereo','eangle'} % equal angle
    
    r =  tan(theta/2);

  case 'edist' % equal distance
    
    r =  theta;

  case {'earea','schmidt'} % equal area

    r =  sqrt(2*(1-cos(theta)));
        
  case 'orthographic'

    r =  sin(theta);
    
  otherwise
    
    error('Unknown Projection!')
    
end

% compute coordinates
X = reshape(cos(rho) .* r,size(v));
Y = reshape(sin(rho) .* r,size(v));
