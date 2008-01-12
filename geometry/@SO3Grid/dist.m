function d = dist(SO3G,q,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
%% usage:  
%  d = find(SO3G,nodes,radius)
%
%% Input
%  SO3G   - @SO3Grid
%  nodes  - @quaternion
%  radius - double
%% Output
%  d      - sparse distance matrix

epsilon = get_option(varargin,'epsilon',2*pi);

if ~check_option(SO3G,'indexed')
  
  d = dist(SO3G.CS,SO3G.SS,q,SO3G.Grid,varargin{:});

else

  % symmetrice
  s = quaternion(SO3G.CS);
  if any(strcmp(Laue(SO3G.CS),{'m-3','m-3m'})) && check_option(varargin,'nocubictrifoldaxis')
    s = s(1:length(s)/3);
  end
  [xalpha,xbeta,xgamma] = quat2euler(transpose(q(:)*s.'));
  
  % find columns with minimal beta angle
  ind = xbeta == repmat(min(xbeta),length(s),1);
  ind = ind & ind == cumsum(ind);
    
  xalpha = xalpha(ind);
  xbeta  = xbeta(ind);
  xgamma = xgamma(ind);
   
  [ybeta,yalpha,ialphabeta,palpha] = getdata(SO3G.alphabeta);

  ygamma = double(SO3G.gamma);
  sgamma = getMin(SO3G.gamma);
  pgamma = getPeriod(SO3G.gamma(1));

  d = SO3Grid_dist_region(yalpha,ybeta,ygamma,sgamma, ...
    int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma,epsilon);
  
  d(SO3G.subGrid,:) = [];
  
end
