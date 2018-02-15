%% *|S2Fun|*
%
% The |S2Fun| toolbox is a collection of Matlab classes for numerical computation with functions on the two-dimensional sphere.
% It overloads the default commands for vectors and matrices to compute the analogous operations for functions of the given type.
% For example the product becomes the pointwise product of two functions.
% Likewise the |min| command finds local minima.
%
% The underlying mathematical approach is accomplished via spherical harmonics which form an orthonormal basis of the square-integrable functions on the two-dimensional sphere.
% Internally for a function $f\colon \bf S^2\to \bf R$ only the corresponding Fourier-coefficients are stored.
%
%% <S2FunHarmonic_index.html *|S2FunHarmonic|*>
%
% <S2FunHarmonic_index |S2FunHarmonic|> forms the basis of |S2Fun|.
% It can handle ordinary functions 
%
% $$f\colon \bf S^2\to \bf R$$
%
% but also multivariate functions
%
% $$ f\colon \bf S^2\to \bf R^n $$.
%
%% <S2FunHarmonicSym_index.html *|S2FunHarmonicSym|*>
%
% <S2FunHarmonic_index |S2FunHarmonic|> is an extension of the <S2FunHarmonic_index |S2FunHarmonic|> class for which you can store the symmetry with the function.
% Various commands are adapted to the symmetry in regards to performance and general function handling.
% For instance the |plot| command only plots the function on the important part of the sphere.
%
%% <S2VectorFieldHarmonic_index.html *|S2VectorFieldHarmonic|*>
%
% <S2VectorFieldHarmonic_index |S2VectorFieldHarmonic|> handles a function 
%
% $$ f\colon \bf S^2\to\bf R^3 $$
%
% which then is interpreted as a vector field.
% For instance the gradient of an univariate <S2FunHarmonic_index |S2FunHarmonic|> can return a <S2VectorFieldHarmonic_index |S2VectorFieldHarmonic|>.
%
%% <S2AxisFieldHarmonic_index.html *|S2AxisFieldHarmonic|*>
%
% <S2AxisFieldHarmonic_index |S2AxisFieldHarmonic|> handles functions of the form 
%
% $$ f\colon \bf S^2\to\bf R^3_{/<\pm \mathrm{Id}>} $$
%
% which can be understood as vectors in $\bf R^3$ without direction or length.
