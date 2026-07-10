function vals = eval_basis_functions(SO3F, varargin)

% decide which basis to use and call the corresponding eval function
% eval on the nodes ori or on the grid of SO3F if ori is not given in varargin
if nargin == 1
  ori = SO3F.nodes;
else
  ori = varargin{1};
  varargin(1) = [];
end

% determine which basis to use and evaluate it on ori
if SO3F.monomials
  if SO3F.tangent
    varargin = set_option(varargin, 'tangent');
  end
  vals = eval_monomials_SO3(ori, SO3F.degree, varargin{:});
else
  vals = eval_monomials_SO3(ori, SO3F.degree, varargin{:});
end

end
