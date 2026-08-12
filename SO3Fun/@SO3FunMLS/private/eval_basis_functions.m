function vals = eval_basis_functions(SO3F, varargin)

  % evaluate the basis on the given orientations, or on SO3F.nodes
  % NOTE: in contrast to S2FunMLS the monomial basis is the only one
  %   implemented here, so SO3F.monomials does not select anything
  if nargin == 1
    ori = SO3F.nodes;
  else
    ori = varargin{1};
    varargin(1) = [];
  end

  if SO3F.tangent
    varargin = set_option(varargin, 'tangent');
  end
  vals = eval_monomials_SO3(ori, SO3F.degree, varargin{:});

end
