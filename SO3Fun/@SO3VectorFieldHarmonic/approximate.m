function SO3VF = approximate(f, varargin)
% Approximate a vector field on the rotation group (SO(3)) in its harmonic 
% representation from a given vector field.
%
% We compute this vector field componentwise, i.e. we compute three
% SO3FunHarmonics individually by quadrature. So, see 
% <SO3VectorFieldHarmonic.quadrature.html |SO3VectorFieldHarmonic.quadrature|> for 
% further information.
%
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.approximate(f)                 % exact computation by quadrature
%   SO3VF = SO3VectorFieldHarmonic.approximate(f,'bandwidth',48)  % exact computation by quadrature
%
% Input
%  f   - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic
%
% Options
%  bandwidth      - maximal harmonic degree (Be careful by setting the bandwidth by yourself, since it may yields undersampling)
%  weights        - corresponding to the nodes (default: Voronoi weights, 'equal': all nodes are weighted similar, numeric array W: specific weights for every node)
%
% See also
% SO3FunHarmonic/approximate SO3VectorFieldHarmonic

SO3VF = SO3VectorFieldHarmonic.quadrature(f,varargin{:});

end
