function [ind,x] = find(S2G,v,epsilon)
% return index of all points in a epsilon neighborhood of a vector
%
%% usage:  
% ind = find(S2G,v,epsilon) - find all points in a epsilon neighborhood of v
% ind = find(S2G,vn)        - find closest point
%
%% Input
%  S2G     - @S2Grid
%  v       - @vector3d
%  epsilon - double
%
%% Output
%  ind     - int32        
%  x       - double


if nargin == 2

  d = dist(S2G,v);
  [ind,x] = find(d==repmat(max(d),size(d,1),1));

  return
end

v = reshape(v,1,[]);

if check_option(S2G.options,'HEMISPHERE')
	v = [v,-v];
end

if ~check_option(S2G.options,'INDEXED')
	ind = find(max(dist(S2G,v),[],2) > cos(epsilon));
	return
end

[ytheta,yrho,iytheta,prho] = getdata(S2G);

[xtheta,xrho] = vec2sph(v);

ind = find_region_2d(ytheta,int32(iytheta),...
  yrho,prho,xtheta,xrho,epsilon);

