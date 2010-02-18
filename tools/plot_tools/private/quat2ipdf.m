function h = quat2ipdf(S3G,varargin)

% get specimen direction
if isa(S3G,'SO3Grid') && strcmpi(get_option(varargin,'r',''),'auto')

  cs = get(S3G,'CS');
  if any(strcmpi(laue(cs),{'m-3m','m-3'}))
    r = sph2vec(pi/6,pi/8);
  else
        
    [maxtheta,maxrho,minrho] = getFundamentalRegionPF(cs,varargin{:});
    maxrho = maxrho - minrho;
    r = sph2vec(pi/4,maxrho/4);
  end
  
else
  
  r = get_option(varargin,'r',xvector,'vector3d');
  
end


% compute crystal directions
h = inverse(S3G) .* r;
