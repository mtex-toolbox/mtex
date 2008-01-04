function ind = find2(SO3G,q,epsilon)
% return indece and distance of all nodes within a eps neighborhood
%
% usage:  [Ind,dist] = find(SO3G,midpoint,radius)
%
%% Input
%  SO3G     - @SO3Grid
%  midpoint - @quaternion
%  radius   - double
%% Output
%  [indece, distances]

[xalpha,xbeta,xgamma] = quat2euler(q);

[ybeta,yalpha,ialphabeta,palpha] = getdata(SO3G.alphabeta);

ygamma = double(SO3G.gamma(1));
pgamma = getPeriod(SO3G.gamma(1));

ind = find_region_3d(yalpha,ybeta,ygamma, int32(ialphabeta),palpha,pgamma,...
  xalpha,xbeta,xgamma,epsilon);

