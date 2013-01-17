function [h,r] = quat2ipdf(ori,varargin)

% get specimen direction
if isa(ori,'orientation') && strcmpi(get_option(varargin,'r',''),'auto')

  cs = get(ori,'CS');
  
  
  switch Laue(cs)
    
    case {'m-3m','m-3'}
      
      r = sph2vec(pi/6,pi/8);
      
    case {'-1','4/m','6/m'}
      
      r = zvector;
      
    case '2/m'
      
      r = yvector;
      
    otherwise
      
      [minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(cs,varargin{:});
      maxRho = maxRho - minRho;
      r = sph2vec(pi/4,maxRho/4);
      
  end   
  
else
  
  r = get_option(varargin,'r',xvector,'vector3d');
  
end


% compute crystal directions
h = inverse(ori) .* r;
