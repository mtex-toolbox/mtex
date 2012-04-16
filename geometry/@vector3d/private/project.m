function [X,Y,hemi,p] = project(v,projection,varargin)




[theta,rho] = polar(v);

if all(strcmpi(projection.hemisphere,'north'))
  %   hemi = true(size(theta));
  hemi = theta <= pi/2;
elseif all(strcmpi(projection.hemisphere,'south'))
%     hemi = false(size(theta));
  hemi = theta < pi/2;
else
  hemi = theta <= pi /2;
end

if ~strcmpi(projection.hemisphere,'plain') 
  theta(~hemi) = pi-theta(~hemi);
end


%% restrict to plotable domain
if ~check_option(varargin,'complete') && (projection.maxrho-projection.minrho<2*pi-1e-6)
  inrho = inside(rho,projection.minrho,projection.maxrho) | isnull(sin(theta));
  
  rho(~inrho)= NaN;
end

if isa(projection.maxtheta,'function_handle')
  theta(theta-1e-6 > projection.maxtheta(rho)) = NaN;
end

%% modify polar coordinates
if projection.drho ~= 0 && ~strcmpi(projection.type,'plain')
  rho = rho + projection.drho;
end

if strcmpi(projection.type,'plain') % do this somehow better
  if projection.flipud, theta = -theta; end
  if projection.fliplr, rho =  -rho; end
else
  if projection.flipud, rho = 2*pi-rho; end
  if projection.fliplr, rho = pi-rho; end
end

%% project data
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

% compute bounding box
if check_option(ensurecell(projection.hemisphere),{'both','south','lower'}) && ~strcmpi(projection.type,'plain')
  
  dgrid = 1*degree;
  dgrid = pi/round((pi)/dgrid);
  
  p = projection;
  if p.maxrho > p.minrho
    rho = p.minrho:dgrid:(p.maxrho-dgrid);
  else
    rho = mod(p.minrho:dgrid:(p.maxrho+2*pi-dgrid),2*pi);
  end
  if p.maxrho ~= 2*pi, rho(1) = [];end
  
  p.hemisphere = 'north';
  [x,y] = project( [sph2vec(0,rho) sph2vec(pi/2,rho)],p);
  offset = max(x)-min(x);
  
  X(~hemi) = X(~hemi) + offset;
end

X = reshape(X,size(v));
Y = reshape(Y,size(v));


p = hemi & check_option(ensurecell(projection.hemisphere),{'both','north','upper','antipodal'});
p(~hemi) = ~hemi(~hemi) & check_option(ensurecell(projection.hemisphere),{'both','south','lower','antipodal'});


function ind = inside(rho,minrho,maxrho)

minr = mod(minrho+1e-6,2*pi)-3e-6;
maxr = mod(maxrho-1e-6,2*pi)+3e-6;
if minr < maxr
  ind = ~(mod(rho-1e-6,2*pi) < minr | mod(rho+1e-6,2*pi) > maxr);
else
  ind = ~(mod(rho-1e-6,2*pi) < minr & mod(rho+1e-6,2*pi) > maxr);
end
