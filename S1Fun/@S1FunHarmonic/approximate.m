function S1F = approximate(f,varargin)
% Approximating an S1FunHarmonic from a given S1Fun by evaluating on a
% quadrature grid and doing quadrature.
%
% Syntax
%   S1F = S1FunHarmonic.approximate(f)
%   S1F = S1FunHarmonic.approximate(f, 'bandwidth', bandwidth)
%
% Input
%  f - @S1FunHandle, @function_handle (first dimension has to be the evaluations)
%
% Output
%  S1F - @S1FunHarmonic
%
% Options
%  bandwidth - minimal degree of the complex exponentials
%
% See also
% S1FunHarmonic.quadrature

S1F = S1FunHarmonic.quadrature(f,varargin{:});
