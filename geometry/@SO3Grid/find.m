function ind = find(SO3G,q,epsilon,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
%% usage:  
% [ind,dist] = find(SO3G,nodes,radius)
%
%% Input
%  SO3G   - @SO3Grid
%  nodes  - @quaternion
%  radius - double
%% Output
%  [indece, distances]
%
%% TODO cubic case

if ~check_option(SO3G,'indexed')

  d = dist(SO3G.CS,SO3G.SS,q,SO3G.Grid);
  
  if nargin == 2
    for i = 1:length(v)
      ind(i) = find(d(:,i) == max(d(:,i)));
    end
  else
    ind = d<epsilon;
  end

else
  
  % symmetrice
  s = quaternion(SO3G.CS);
  if any(strcmp(Laue(SO3G.CS),{'m-3','m-3m'})) && check_option(varargin,'nocubictrifoldaxis')
    s = s(1:length(s)/3);
  end
  [xalpha,xbeta,xgamma] = quat2euler(transpose(q(:)*s.'));
  
  % find columns with minimal beta angle
  ind = xbeta == repmat(min(xbeta),length(SO3G.CS),1);
  ind = ind & ind == cumsum(ind);
    
  xalpha = xalpha(ind);
  xbeta  = xbeta(ind);
  xgamma = xgamma(ind);
   
  [ybeta,yalpha,ialphabeta,palpha] = getdata(SO3G.alphabeta);

  ygamma = double(SO3G.gamma);
  sgamma = getMin(SO3G.gamma);
  pgamma = getPeriod(SO3G.gamma(1));

  if nargin == 2

    % insert here loop for cubic case
    
    ind = SO3Grid_find(yalpha,ybeta,ygamma,sgamma, ...
      int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma);
      
  else
  
    ind = SO3Grid_find_region(yalpha,ybeta,ygamma,sgamma, ...
      int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma,epsilon);
  
    ind(SO3G.subGrid,:) = [];
  end
  
end
