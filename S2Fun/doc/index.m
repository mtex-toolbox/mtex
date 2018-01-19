%% *|S2Fun|*
%
% The |S2Fun| toolbox is a collection of MATLAB(R) classes for numerical computation with functions on the twodimensional sphere.
% It overloads the default commands for vectors and matrices to compute the analoguous operations for functions of the given type.
% For example the product becomes the pointwise product of two functions.
% Likewise the |min| command finds local minimas.
%
% The underlying mathematical approach is accomplished via spherical harmonics which form an orthonormal basis on the twodimensional sphere.
% Internaly for a function $f\colon \bf S^2\to \bf R$ only the corresponding Fourier-coefficients are stored.
%
%% <basicFunction.html *|S2FunHarmonic|*>
%
% |S2FunHarmonic| forms the basis of |S2Fun|.
% It can handle ordinary functions 
%
% $$f\colon \bf S^2\to \bf R$$
%
% but also multimodal function 
%
% $$ f\colon \bf S^2\to \bf R^n $$.
%
%% <symmetrisedFunction.html *|S2FunHarmonicSym|*>
%
% |S2FunHarmonic| is an extension of the |S2FunHarmonic| class for which one can store the symmetry with the function.
% Various commands are adapted to the symmetry in regards to performance and general function handling.
% For instance the |plot| command only plots the function on the important part of the sphere.
%
%% <VectorField.html *|S2VectorFieldHarmonic|*>
%
% |S2VectorFieldHarmonic| handles a function 
%
% $$ f\colon \bf S^2\to\bf R^3 $$
%
% wich then is interpreted as a vector field.
% For instance the gradient of an unimodal |S2Fun| can return a |S2VectorFieldHarmonic|.
%
%% <AxisField.html *|S2AxisFieldHarmonic|*>
%
% |S2AxisFieldHarmonic| handles functions of the form 
%
% $$ f\colon \bf S^2\to\bf R^3_{/<\pm \mathrm{Id}>} $$
%
% which can be understood as vectors in $\bf R^3$ without direction or length.
