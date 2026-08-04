function vals = eval_basis_functions(S2F, varargin)

% evaluate the selected basis on the supplied nodes, or on S2F.nodes
if nargin == 1
  v = S2F.nodes;
else
  v = varargin{1};
  varargin(1) = [];
end

if S2F.monomials
  if S2F.tangent
    varargin = set_option(varargin, 'tangent');
  end
  vals = eval_monomials_S2(v, S2F.degree, varargin{:});
else
  vals = eval_spherical_harmonics(v, S2F.degree);
end

end
