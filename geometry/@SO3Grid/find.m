function [ind,d] = find(SO3G,q,epsilon,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
%% Syntax  
% [ind,dist] = find(SO3G,nodes,radius)
%
%% Input
%  SO3G   - @SO3Grid
%  nodes  - @quaternion
%  radius - double
%% Output
%  [indece, distances]
%


if ~check_option(SO3G,'indexed') || check_option(varargin,'exact')

  d = dist(SO3G.CS,SO3G.SS,q,SO3G.Grid);
  
  if nargin == 2
    ind = zeros(1,length(v));
    for i = 1:length(v)
      ind(i) = find(d(:,i) == max(d(:,i)));
    end
  else
    ind = d<epsilon;
  end

elseif GridLength(SO3G) == 0
  ind = [];
  d = [];
else
  
  % symmetrice
  s = quaternion_special(SO3G.CS);
  ls = length(s);
  lq = numel(q);
  
  % special cubic case 1
  if any(strcmp(Laue(SO3G.CS),{'m-3','m-3m'})) && check_option(varargin,'nocubictrifoldaxis')
    s = s(1:ls/3);
  end
  
  qs = q(:)*s.'; clear q; % rows symmetries, columns elements

  % convert to euler
  [xalpha,xbeta,xgamma] = quat2euler(qs); clear qs;
  
  % extract SO3Grid
  [ybeta,yalpha,ialphabeta,palpha] = getdata(SO3G.alphabeta);

  ygamma = double(SO3G.gamma);
  igamma = cumsum([0,GridLength(SO3G.gamma)]);
  sgamma = getMin(SO3G.gamma);
  pgamma = getPeriod(SO3G.gamma(1));

  if nargin == 2 % search for nearest
  
    [ind,d] = SO3Grid_find(yalpha,ybeta,ygamma,sgamma,int32(igamma), ...
      int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma);    
    
    d = reshape(d,[],numel(s)); ind = reshape(ind,[],numel(s));
      
    [d,ind] = selectMaxbyRow(d,ind);
      
  else  % search for environment
    
    ind = SO3Grid_find_region(yalpha,ybeta,ygamma,sgamma,int32(igamma), ...
      int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma,epsilon);
    
    ind = reshape(ind,[],numel(s));
    ind = reshape(any(ind,2),[GridLength(SO3G) lq]);
  end  
end
