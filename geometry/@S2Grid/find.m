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

ind = [];
v = reshape(v,1,[]);


if check_option(S2G.options,'HEMISPHERE')
	v = [v,-v];
end

if ~check_option(S2G.options,'INDEXED')
	ind = find(max(dist(S2G,v),[],2) > cos(epsilon));
	return
end

thetaindex = cumsum([0,GridLength(S2G.rho)]);
for iter=1:length(v)
	
	[theta,rho] = vec2sph(v(iter));

	% get theta intervall
	itheta = find(S2G.theta,theta,epsilon);
	S2Gtheta = double(S2G.theta);

	% get corresponding rho
	for ith = itheta

		theta2 = S2Gtheta(ith);
		cs = cos(theta)*cos(theta2);
		ss = sin(theta)*sin(theta2);
		
		if isnull(ss) || (cos(epsilon)-cs)/ss < -0.9999 
			% close to north-pole -> all points
			dI =  1:GridLength(S2G.rho(ith));

		elseif  cs + ss > cos(epsilon) 
			tol = acos((cos(epsilon)-cs)/ss);
			dI =  find(S2G.rho(ith),rho,tol);
		end
		ind = [ind,thetaindex(ith) + dI]; %#ok<AGROW>
	end
end
ind = cunion(ind);
