function h = quat2ipdf(ori,varargin)

% get specimen direction
if isa(ori,'orientation') && strcmpi(get_option(varargin,'r',''),'auto')

  cs = get(ori,'CS');
  if any(strcmpi(Laue(cs),{'m-3m','m-3'}))
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
h = inverse(ori) .* r;
