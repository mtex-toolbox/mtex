function d = dot_outer(S3G,q,varargin)
% return outer inner product of all nodes within a eps neighborhood
%
%% Syntax  
%  d = dot_outer(SO3G,nodes,'epsilon',radius)
%
%% Input
%  SO3G   - @SO3Grid
%  nodes  - @quaternion
%  radius - double
%% Output
%  d      - sparse matrix
%
%% formuala:
% cos angle(g1,g2)/2 = dot(g1,g2)

if ~isa(S3G,'SO3Grid')
  d = dot_outer(q,S3G,varargin{:}).';
  return
end

epsilon = get_option(varargin,'epsilon',pi);

if check_option(varargin,{'full','all'})
  
  d = dot_outer(orientation(S3G),q,varargin{:});
  
else
  
  d = sparse(numel(S3G),numel(q));
  
  % rotate q according to SO3Grid.center
  if ~isempty(S3G.center),q = inverse(S3G.center) * q; end
  
  % extract SO3Grid
  [ybeta,yalpha,ialphabeta,palpha] = getdata(S3G.alphabeta);
  
  ygamma = double(S3G.gamma);
  sgamma = getMin(S3G.gamma);
  pgamma = getPeriod(S3G.gamma(1));
  igamma = cumsum([0,GridLength(S3G.gamma)]);
  
  % correct for specimen symmetry
  if check_option(varargin,'nospecimensymmetry')
    qss = idquaternion;
    palpha = 2*pi;
  else
    qss = quaternion(rotation_special(S3G.SS));
    palpha = max(palpha,pi);
  end
  
  % for finding the minimial beta angle
  qcs = quaternion(rotation_special(S3G.CS));
  
  [xalpha,xbeta,xgamma] = Euler( qss * q * qcs ,'ZYZ');
  
  ncs = numel(qss)*numel(qcs);
  cs = 0:numel(q):ncs*numel(q);
  
  for k=1:ncs
  
    ndx = cs(k)+1:cs(k+1);
  
    dist = SO3Grid_dist_region(yalpha,ybeta,ygamma, ...
      sgamma, int32(igamma), int32(ialphabeta), palpha, pgamma, ...
      xalpha(ndx), xbeta(ndx), xgamma(ndx), epsilon);
      
    if nnz(dist) > 0, d = max(d,dist); end
    
  end    
  
end
