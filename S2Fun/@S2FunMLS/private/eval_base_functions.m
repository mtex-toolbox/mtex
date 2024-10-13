function base_vals = eval_base_functions(sF, varargin)

% decide which bases to use and call the corresponding eval function
% eval on the nodes v or on the grid of sF if v is not given in varargin
if nargin == 1
  v = sF.nodes;
else
  v = varargin{1};
end

% determine which basis to use and evaluate it on v
if sF.all_degrees
  if sF.monomials
    base_vals = [eval_monomials(v, sF.degree) ... 
      eval_monomials(v, sF.degree-1)];
  else
    base_vals = [eval_spherical_harmonics(v, sF.degree) ...
      eval_spherical_harmonics(v, sF.degree-1)];
  end
else
  if sF.monomials
    base_vals = eval_monomials(v, sF.degree);
  else
    base_vals = eval_spherical_harmonics(v, sF.degree);
  end
end

end
