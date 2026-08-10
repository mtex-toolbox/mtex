%% The Spherical Radon Transform
%%
%
% The spherical Radon transform $\mathcal R$ replaces the value of a
% function at a point by its mean value along the great circle
% perpendicular to that point,
%
% $$ \mathcal R f(\vec x) = \frac{1}{2\pi}\int_{\vec v \perp \vec x} f(\vec v)\,\mathrm{d}\vec v. $$
%
% It is the spherical analogue of the classical Radon transform behind
% computer tomography, and in texture analysis it is the operation that
% turns an ODF into a <PoleFigureSimulation.html pole figure>. This page
% treats it for ordinary spherical functions; see
% <SO3Fun.calcPDF.html |calcPDF|> for the orientation space version.
%
%% Computing the transform
%
% Let us start with a simple unimodal function on the sphere

f = @(v) exp(-4 * angle(v,vector3d(1,1,1)).^2);

sF = S2FunHarmonic.quadrature(f,'bandwidth',48)

%%

plot(sF,'upper')
mtexColorbar

%%
% Its Radon transform is computed by <S2FunHarmonic.radon.html |radon|>

rF = radon(sF)

%%

plot(rF,'upper')
mtexColorbar

%%
% The single maximum has become a ring - the great circles that pass
% through the peak are exactly those whose pole lies 90 degree away from
% it.
%
% We can check the definition directly. Take an arbitrary direction, walk
% around the great circle perpendicular to it and average.

x = normalize(vector3d(0.3,-0.7,0.5));

u1 = orth(x); u2 = cross(x,u1);
t = 2*pi*(0:1e5-1).'/1e5;
v = cos(t) .* u1 + sin(t) .* u2;

[mean(sF.eval(v)), rF.eval(x)]

%% Why it is a convolution
%
% Averaging over great circles is rotationally invariant, hence
% $\mathcal R$ is a convolution and acts diagonally on the harmonic
% expansion. Its Legendre coefficients are
%
% $$ A_n = (-1)^{n/2}\,\frac{(n-1)!!}{n!!} \quad\text{for even } n, \qquad A_n = 0 \quad\text{for odd } n. $$
%
% The vanishing odd coefficients are the essential point: *the Radon
% transform destroys the odd part of a function*. Applying it to a purely
% odd function gives zero up to numerical noise

sFodd = S2FunHarmonic.quadrature(@(v) v.z,'bandwidth',8);

max(abs(radon(sFodd)))

%%
% This is unavoidable, not a shortcoming of the implementation - a great
% circle contains a direction together with its antipode, so no averaging
% over great circles can ever distinguish $f(\vec v)$ from $f(-\vec v)$.
% Every Radon transform is <VectorsAxes.html antipodally symmetric>.
%
%% Mean values along small circles
%
% Passing a second argument $\delta$ replaces the great circle by the small
% circle at angular distance $\pi/2 + \delta$ from $\vec x$

delta = 20*degree;

rD = radon(sF,delta);

w = cos(pi/2+delta) * x + sin(pi/2+delta) * (cos(t) .* u1 + sin(t) .* u2);

[mean(sF.eval(w)), rD.eval(x)]

%%

plot(rD,'upper')
mtexColorbar

%% Inverting the transform
%
% Since $\mathcal R$ is diagonal in the harmonic basis, inverting it is a
% matter of dividing by the coefficients $A_n$. This is what
% <S2FunHarmonic.invRadon.html |invRadon|> does.

backF = invRadon(rF)

%%
% For a function that is already antipodally symmetric the round trip is
% exact

sFeven = S2FunHarmonic.quadrature(@(v) 0.5*(f(v) + f(-v)),'bandwidth',48);

nodes = equispacedS2Grid('resolution',5*degree);

mean(abs(invRadon(radon(sFeven)).eval(nodes) - sFeven.eval(nodes)))

%%
% For a general function it is not - what comes back is precisely the even
% part, and the odd part is gone for good

mean(abs(backF.eval(nodes) - sF.eval(nodes)))

%%

mean(abs(backF.eval(nodes) - sFeven.eval(nodes)))

%%
% Note also that $A_n$ decays like $n^{-1/2}$, so the inverse multiplies
% high harmonics by a growing factor and amplifies noise. On measured data
% one should therefore not invert the transform directly but solve a
% regularized problem - which is exactly what
% <PoleFigure2ODF.html ODF reconstruction from pole figures> does. The lost
% odd part is what reappears there as the
% <PoleFigure2ODFAmbiguity.html ghost effect>.

%#ok<*NOPTS>
