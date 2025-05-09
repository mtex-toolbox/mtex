function basis_values = eval_basis_functions(sF, varargin)

% eval on the nodes ori or on the grid of sF if ori is not given 
if nargin == 1
  ori = sF.nodes;
else
  ori = varargin{1};
end

if (sF.degree == 0)
  basis_values = ones(size(ori));
  return;
end

% determine which basis to use and evaluate it on ori
if sF.all_degrees
    basis_values = [eval_monomials_S3(ori, sF.degree) ...
      eval_monomials_S3(ori, sF.degree-1)];
else
    basis_values = eval_monomials_S3(ori, sF.degree, sF.tangent);
end

end
