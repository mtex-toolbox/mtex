function [ind,d] = find(S2G,v,epsilon,varargin)
% return index of all points in a epsilon neighborhood of a vector
%
%% Syntax  
% ind = find(S2G,v,epsilon) - find all points in a epsilon neighborhood of v
% ind = find(S2G,v)         - find closest point
%
%% Input
%  S2G     - @S2Grid
%  v       - @vector3d
%  epsilon - double
%
%% Options
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]
%
%% Output
%  ind     - int32        

if check_option(S2G.options,'INDEXED') && ~check_option(varargin,'direct')
  
  d = [];
  if check_option(S2G.options,'antipodal'), v = [v(:),-v(:)]; end

  [ytheta,yrho,iytheta,prho,rhomin] = getdata(S2G);
  yrho = yrho - rhomin;
  [xtheta,xrho] = vec2sph(v);
  xrho = xrho - rhomin;

  if nargin == 2
    ind = S2Grid_find(ytheta,int32(iytheta),...
      yrho,prho,xtheta,xrho);
    
    if check_option(S2G.options,'antipodal')    
      ind = reshape(ind,[],2);
%      for i = 1:size(ind,1)
%        d = abs(dot(S2G.Grid(ind(i,:)),v(i)));
%        if d(1) < d(2), ind2(i) = ind(i,2);else ind2(i) = ind(i,1);end
%      end                 
      
      d = abs(dot(S2G(ind),v));
      ind2 = d == repmat(max(d,[],2),1,2);
      ind2(all(ind2,2),2) = false;
      ind = ind(ind2);
      d = d(ind2);
   
    end
  else
    ind = S2Grid_find_region(ytheta,int32(iytheta),...
      yrho,prho,xtheta,xrho,epsilon);
    
    if check_option(S2G.options,'antipodal')    
      ind = ind(:,1:size(v,1)) | ind(:,size(v,1) + 1:end);
    end
  end
else % not indexed points

  d = dot_outer(S2G,v);
  
  if nargin >= 3
    ind = d > cos(epsilon);
  else   
    [d,ind] = max(d,[],1);
  end
end
