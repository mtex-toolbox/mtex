function [h,r] = quat2ipdf(ori,varargin)

% get specimen direction
if isa(ori,'orientation') && ...
    (strcmpi(get_option(varargin,'r',''),'auto') ||...
  check_option(varargin,'sharp'))
   
  % compute the center of the fundamental region
  cs = get(ori,'CS');
    
  switch Laue(cs)
    
    case {'m-3m','m-3'}
      
      center = sph2vec(pi/6,pi/8);
      
    case {'-1','4/m','6/m'}
      
      center = zvector;
      
    case '2/m'
      
      center = yvector;
      
    otherwise
      
      [minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(cs,varargin{:});      
      maxRho = maxRho - minRho;
      if check_option(varargin,'antipodal'), maxRho = maxRho * 2;end
      center = sph2vec(pi/4,maxRho/4);
      
  end

  % compute r such that mean(ori)^-1 * r = center
  r = mean(ori) * center;
  
else
  
  r = get_option(varargin,'r',xvector,'vector3d');
  
end


% compute crystal directions
h = inverse(ori) .* r;
