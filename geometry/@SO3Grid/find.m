function [ind,d] = find(SO3G,o,epsilon,varargin)
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

  d = angle_outer(SO3G,o);
  
  if nargin == 2
    [d,ind] = max(d,[],1);
  else
    ind = d<epsilon;
  end

elseif numel(SO3G) == 0
  ind = [];
  d = [];
else
  q = quaternion(o);
  
  % rotate q according to SO3Grid.center
  if ~isempty(SO3G.center),q = inverse(SO3G.center) * q; end
    
  % correct for crystal and specimen symmetry
  qcs = quaternion_special(SO3G.CS);
  qss = quaternion_special(SO3G.SS);
  
  % extract SO3Grid
  [ybeta,yalpha,ialphabeta,palpha] = getdata(SO3G.alphabeta);
  palpha = max(palpha,pi);
  ygamma = double(SO3G.gamma);
  igamma = cumsum([0,GridLength(SO3G.gamma)]);
  sgamma = getMin(SO3G.gamma);
  pgamma = getPeriod(SO3G.gamma(1));

  if nargin == 2 
%% search for nearest neighbour

    d = zeros(numel(q),1);
    ind = zeros(numel(q),1);
    
    for is = 1:length(qss)
      for ic = 1:length(qcs)

        [xalpha,xbeta,xgamma] = quat2euler(qss(is) * transpose(q(:)*qcs(ic)));
  
        [hind,hd] = SO3Grid_find(yalpha,ybeta,ygamma,sgamma,int32(igamma), ...
          int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma);

        ind_better = hd > d;
        ind(ind_better) = hind(ind_better);
        d  = max(hd,d);
            
      end
    end    
  else  
%% search for environment    
    ind = logical(sparse(numel(SO3G),numel(q)));
    
    % for all symmetries
    for is = 1:length(qss)
      for ic = 1:length(qcs)

        [xalpha,xbeta,xgamma] = quat2euler(qss(is) * transpose(q(:)*qcs(ic)));
  
        ind = ind | SO3Grid_find_region(yalpha,ybeta,ygamma,sgamma,int32(igamma), ...
          int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma,epsilon);
            
      end
    end
  end  
end
