function [v,l] = symmetrise(v,S,varargin)
% symmetrcially equivalent directions and its multiple
%
%% Input
%  v - @vector3d
%  S - @symmetry
%
%% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%
%% Output
%  Sv - symmetrically equivalent vectors
%  l  - number of symmetrically equivalent vectors

if nargout == 2
  
  l = zeros(size(v));
  
  Sv = vector3d;
  for i=1:length(v)
	
    h = S * subsref(v,i);
    u = subsref(v,1);
    for j = 2:length(h)
      if ~any(isnull(norm(u-subsref(h,j))))...
          && ~(check_option(varargin,'antipodal') && any(isnull(norm(u+subsref(h,j)))))
        u = [u,subsref(h,j)]; %#ok<AGROW>
      end
    end
    h = u;
    Sv = [Sv,h]; %#ok<AGROW>
    l(i) = length(h);
  end
  v = Sv.';
else
  
  v = S * v;

  if check_option(varargin,'antipodal')
    v = [v;-v];
    if check_option(varargin,'plot')
      del = v.z<-1e-6;
      v.x(del) = [];
      v.y(del) = [];
      v.z(del) = [];
    end
  end

  if size(v,2) == 1
    v = cunion(v).';
  end
end
