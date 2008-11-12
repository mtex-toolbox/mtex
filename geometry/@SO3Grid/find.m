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


if ~check_option(SO3G,'indexed')

  d = dist(SO3G.CS,SO3G.SS,q,SO3G.Grid);
  
  if nargin == 2
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
  
  qs = transpose(q(:)*s.'); clear q; % rows symmetries, columns elements

  % special cubic case 2 -> check trifold axis seperatly
  if any(strcmp(Laue(SO3G.CS),{'m-3','m-3m'})) && ~check_option(varargin,'nocubictrifoldaxis')
    qs = [qs(1:ls/3,:),qs(ls/3+1:2*ls/3,:),qs(2*ls/3+1:end,:)];
  end

  % convert to euler and find rows with minimal beta angle
  [xalpha,xbeta,xgamma] = quat2euler(qs);   clear qs;
  [xbeta,xalpha,xgamma] = selectMinbyRow(xbeta,xalpha,xgamma);
  
  % extract SO3Grid
  [ybeta,yalpha,ialphabeta,palpha] = getdata(SO3G.alphabeta);

  ygamma = double(SO3G.gamma);
  igamma = cumsum([0,GridLength(SO3G.gamma)]);
  sgamma = getMin(SO3G.gamma);
  pgamma = getPeriod(SO3G.gamma(1));

  if nargin == 2
  
    [ind,d] = SO3Grid_find(yalpha,ybeta,ygamma,sgamma,int32(igamma), ...
      int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma);    
    
    if any(strcmp(Laue(SO3G.CS),{'m-3','m-3m'})) && ~check_option(varargin,'nocubictrifoldaxis')          

      d = reshape(d,[],3); ind = reshape(ind,[],3);
      
      [d,ind] = selectMaxbyColumn(d,ind);
      
    end      
  else  
    ind = SO3Grid_find_region(yalpha,ybeta,ygamma,sgamma,int32(igamma), ...
      int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma,epsilon);
    
    % special cubic case 2
    if any(strcmp(Laue(SO3G.CS),{'m-3','m-3m'})) && ~check_option(varargin,'nocubictrifoldaxis')
      ind = reshape(ind,[],3);
      ind = reshape(any(ind,2),[GridLength(SO3G) lq]);
    end    
  end  
end
