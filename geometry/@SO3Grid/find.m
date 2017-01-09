function [ind,d] = find(SO3G,o,epsilon,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
% Syntax  
%   [ind,dist] = find(SO3G,nodes,radius)
%
% Input
%  SO3G   - @SO3Grid
%  nodes  - @quaternion
%  radius - double
%
% Output
%  ind  - index of the closes grid point
%  dist - misorientation angle
%

if check_option(varargin,'exact')

  d = dot_outer(SO3G,o);
  
  if isempty(epsilon)
    [d,ind] = max(d,[],1);
  else
    ind = d>cos(epsilon/2);
  end

elseif isempty(SO3G)
  
  ind = [];
  d = [];
  
else
  
  q = quaternion(o);
  
  % rotate q according to SO3Grid.center
  if ~isempty(SO3G.center), q = inv(SO3G.center) * q; end %#ok<MINV>
    
  % correct for crystal and specimen symmetry
  qcs = quaternion(rotation_special(SO3G.CS));
  qss = quaternion(rotation_special(SO3G.SS));
  
  % extract SO3Grid
  [ybeta,yalpha,ialphabeta,palpha] = getdata(SO3G.alphabeta);
  palpha = max(palpha,pi);
  ygamma = double(SO3G.gamma);
  igamma = cumsum([0,GridLength(SO3G.gamma)]);
  sgamma = [SO3G.gamma.min];
  pgamma = SO3G.gamma(1).period;

  % search for nearest neighbour
  if nargin == 2 

    d = zeros(length(q),1);
    ind = zeros(length(q),1);
    
    for is = 1:length(qss)
      for ic = 1:length(qcs)

        [xalpha,xbeta,xgamma] = Euler(qss(is) * transpose(q(:)*qcs(ic)),'ZYZ');
  
        [hind,hd] = SO3Grid_find(yalpha,ybeta,ygamma,sgamma,int32(igamma), ...
          int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma);

        ind_better = hd > d;
        ind(ind_better) = hind(ind_better);
        d  = max(hd,d);
            
      end
    end    
    
  else % search for environment    
    
    ind = logical(sparse(length(SO3G),length(q)));
    
    % for all symmetries
    for is = 1:length(qss)
      for ic = 1:length(qcs)

        [xalpha,xbeta,xgamma] = Euler(qss(is) * transpose(q(:)*qcs(ic)),'ZYZ');
  
        ind = ind | SO3Grid_find_region(yalpha,ybeta,ygamma,sgamma,int32(igamma), ...
          int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma,epsilon);
            
      end
    end
  end  
end
