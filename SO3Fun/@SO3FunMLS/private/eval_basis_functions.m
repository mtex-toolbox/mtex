function base_vals = eval_basis_functions(sF, varargin)

% eval on the nodes ori or on the grid of sF if ori is not given in varargin
if nargin == 1
  ori = sF.nodes;
else
  ori = varargin{1};
end

% determine which basis to use and evaluate it on ori
if sF.all_degrees
    base_vals = [eval_monomials_S3(ori, sF.degree) ...
      eval_monomials_S3(ori, sF.degree-1)];
else
    base_vals = eval_monomials_S3(ori, sF.degree, sF.tangent);
end

end
