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

epsilon = get_option(varargin,'epsilon',pi);
if isa(q,'SO3Grid'), q = quaternion(q);end
d = sparse(GridLength(SO3G),numel(q));

if ~check_option(SO3G,'indexed') || check_option(varargin,'full')
  
  d = cos(dist(SO3G.CS,SO3G.SS,SO3G.Grid(:),q(:).',varargin{:})/2);

else

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
  
  %% correct for trifold cubic axis
  %if any(strcmp(Laue(SO3G.CS),{'m-3','m-3m'})) 
  %  qcs = s(1:2:end);
  %  s = s(1:length(s)/3);
  %else 
  %  qcs = idquaternion;
  %end

  % for all specimen symmetries 
  for is = 1:length(qss)
    for ic = 1:length(qcs)

      [xalpha,xbeta,xgamma] = quat2euler(qss(is) * ...
        transpose(q(:)*qcs(ic)));
  
      % find columns with minimal beta angle
      %[xbeta,xalpha,xgamma] = selectMinbyRow(xbeta,xalpha,xgamma);
      
      d = max(d,SO3Grid_dist_region(yalpha,ybeta,ygamma,sgamma,int32(igamma),...
        int32(ialphabeta),palpha,pgamma, xalpha,xbeta,xgamma,epsilon));
    
    end    
  end
end
