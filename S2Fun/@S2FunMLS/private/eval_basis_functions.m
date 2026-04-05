function vals = eval_basis_functions(sF, varargin)

% decide which basis to use and call the corresponding eval function
% eval on the nodes v or on the grid of sF if v is not given in varargin
if nargin == 1
  v = sF.nodes;
else
  v = varargin{1};
end

% determine which basis to use and evaluate it on v
if sF.monomials
  vals = eval_monomials_S2(v, sF.degree, sF.tangent);
else
  vals = eval_spherical_harmonics(v, sF.degree);
end

end
