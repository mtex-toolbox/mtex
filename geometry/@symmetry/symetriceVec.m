function [Sv,l] = symetriceVec(S,v,varargin)
% symmetrcially equivalent directions and its multiple
%
%% Input
%  S - @symmetry
%  v - @vector3d
%
%% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%
%% Output
%  Sv - symmetrically equivalent vectors
%  l  - number of symmetrically equivalent vectors

l = [];
Sv = vector3d;
for i=1:length(v)
	
	h = S.quat * v(i);		
	u = h(1);
	for j = 2:length(h)
		if ~any(isnull(norm(u-h(j))))...
      && ~(check_option(varargin,'antipodal') && any(isnull(norm(u+h(j)))))
			u = [u,h(j)]; %#ok<AGROW>
		end
	end
	h = u;
	Sv = [Sv,h]; %#ok<AGROW>
	l(i) = length(h);
	
end
