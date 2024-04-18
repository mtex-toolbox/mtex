function [vF1,vF2] = tangential(r,varargin)
% reference vector field on the pole figure

if nargin == 1

  vF1 = local(r);
  vF2 = localOrth(r);

else  
  vF1 = S2VectorFieldHandle(@(r) local(r));
  vF2 = S2VectorFieldHandle(@(r) localOrth(r));
end

  function v = local(r)
    
    %    v = normalize(rRef - r);
    %    v = normalize(v - dot(v,r) .* r);
    
    v = orth(r);

    %ind = isnan(v);
    %if any(ind)
    %  v(ind) = 
    
  end

  function v = localOrth(r)

    v = cross(r,local(r));
    %v = normalize(rRef - r);
    %v = normalize(cross(r,v));
  end

end

