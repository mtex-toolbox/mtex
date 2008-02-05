function d = dot_outer(SO3G,q,varargin)
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
% cos angle(g1,g2)/2 = dout(g1,g2)

epsilon = get_option(varargin,'epsilon',2*pi);
if isa(q,'SO3Grid'), q = quaternion(q);end

if ~check_option(SO3G,'indexed') || check_option(varargin,'full')
  
  d = cos(dist(SO3G.CS,SO3G.SS,q,SO3G.Grid,varargin{:})/2);

else

  % symmetrice
  s = quaternion_special(SO3G.CS);
  if any(strcmp(Laue(SO3G.CS),{'m-3','m-3m'})) && check_option(varargin,'nocubictrifoldaxis')
    s = s(1:length(s)/3);
  end
  [xalpha,xbeta,xgamma] = quat2euler(transpose(q(:)*s.'));
  
  % find columns with minimal beta angle
  ind = xbeta == repmat(min(xbeta,[],1),length(s),1);
  ind = ind & ind == cumsum(ind,1);
    
  xalpha = xalpha(ind);
  xbeta  = xbeta(ind);
  xgamma = xgamma(ind);
   
  [ybeta,yalpha,ialphabeta,palpha] = getdata(SO3G.alphabeta);

  ygamma = double(SO3G.gamma);
  sgamma = getMin(SO3G.gamma);
  pgamma = getPeriod(SO3G.gamma(1));
  igamma = cumsum([0,GridLength(SO3G.gamma)]);

  d = SO3Grid_dist_region(yalpha,ybeta,ygamma,sgamma,int32(igamma),...
    int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma,epsilon);
   
end
