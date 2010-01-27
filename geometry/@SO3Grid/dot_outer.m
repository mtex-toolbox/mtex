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
% cos angle(g1,g2)/2 = dot(g1,g2)

epsilon = get_option(varargin,'epsilon',pi);
q = quaternion(q);

if ~check_option(SO3G,'indexed') || check_option(varargin,{'full','all'})
  
  d = dot_outer(SO3G.orientation,q,varargin{:});
  
else
  d = sparse(numel(SO3G),numel(q));
  
  % rotate q according to SO3Grid.center
  if ~isempty(SO3G.center),q = inverse(SO3G.center) * q; end
  
  % extract SO3Grid
  [ybeta,yalpha,ialphabeta,palpha] = getdata(SO3G.alphabeta);
  
  ygamma = double(SO3G.gamma);
  sgamma = getMin(SO3G.gamma);
  pgamma = getPeriod(SO3G.gamma(1));
  igamma = cumsum([0,GridLength(SO3G.gamma)]);
  
  % correct for specimen symmetry
  if check_option(varargin,'nospecimensymmetry')
    qss = idquaternion;
    palpha = 2*pi;
  else
    qss = quaternion_special(SO3G.SS);
    palpha = max(palpha,pi);
  end
  
  % for finding the minimial beta angle
  qcs = quaternion_special(SO3G.CS);
  
  % for all symmetries 
  for is = 1:length(qss)
    for ic = 1:length(qcs)

      [xalpha,xbeta,xgamma] = Euler(qss(is) * ...
        transpose(q(:)*qcs(ic)));
  
      d = max(d,SO3Grid_dist_region(yalpha,ybeta,ygamma,sgamma,int32(igamma),...
        int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma,epsilon));
    
    end    
  end
end
