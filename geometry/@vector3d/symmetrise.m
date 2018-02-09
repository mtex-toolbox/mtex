function [v,l,sym] = symmetrise(v,S,varargin)
% symmetrcially equivalent directions and its multiple
%
% Input
%  v - @vector3d
%  S - @symmetry
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%
% Output
%  Sv - symmetrically equivalent vectors
%  l  - number of symmetrically equivalent vectors

% TODO
% symmetrise behaviour for case 1 and option 'antipodal' is not very
% intuitive
% we should use the option unique to get the unique symmetric equivalent!!

if nargout > 1
  
  l = zeros(size(v));
  sym = rotation;
  
  Sv = v;
  Sv.x = []; Sv.y = []; Sv.z = [];
  
  % how to deal with antipodal symmetry
  isAnti = check_option(varargin,'antipodal');
  keepAnti = check_option(varargin,'keepAntipodal');
  
  for i=1:length(v)
  
    u = v.subSet(i);
    sym = [sym,S(1)];
    
    h = S * u;
    if isAnti && keepAnti
      h = [h;-h]; %#ok<AGROW>
    end
        
    for j = 2:length(h)
      
      hj = h.subSet(j);
      if ~any(isnull(norm(u-hj))) ...
          && ~(~keepAnti && isAnti && any(isnull(norm(u + hj))))
        u = [u,hj]; %#ok<AGROW>
        sym = [sym,S(j)]; %#ok<AGROW>
      end
      
    end
    h = u;
    Sv = [Sv,h]; %#ok<AGROW>
    l(i) = length(h);
  end
  v = Sv.';
else
  
  v = reshape(S * v,length(S),length(v));

  if (check_option(varargin,'antipodal') || v.antipodal) ...
      && ~check_option(varargin,'skipAntipodal')
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
  
  if check_option(varargin,'unique')
    [~,ind] = unique(vector3d(v));
    v = subSet(v,ind);
  end
  
    
end
