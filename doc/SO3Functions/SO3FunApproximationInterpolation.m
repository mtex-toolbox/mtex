%% Approximating Orientation Dependent Functions from Discrete Data
%
%%
% On this page we consider the problem of determining a smooth orientation
% dependent function $f(\mathtt{ori})$ given a list of orientations
% $\mathtt{ori}_n$ and a list of corresponding values $v_n$. These values
% may be the volume of crystals with a specific orientation, as in the
% case of an ODF, or any other orientation dependent physical property.
%
% Orientation dependent data may be stored in ASCII files with lines of
% Euler angles, representing the orientations, and values. Such data files
% can be imported by the command <orientation.load.html
% |orientation.load|>, where we have to specify the position of the columns
% of the Euler angles as well as of the additional properties.

fname = fullfile(mtexDataPath, 'orientation', 'dubna.csv');
[ori, S] = orientation.load(fname,'columnNames',{'phi1','Phi','phi2','values'});

%%
% As a result the command returns a list of orientations |ori| and a struct
% |S|. The struct contains one field for each additional column in our data
% file. In our toy example it is the field |S.values|. Lets generate a
% discrete plot of the given orientations |ori| together with the values
% |S.values|.

plotSection(ori, S.values,'all','sigma');

%%
% The process of finding a function which coincides with the given function
% values in the nodes reasonably well is called approximation. MTEX support
% different approximation schemes: approximation by harmonic expansion,
% approximation by radial functions and approximation by a Bingham
% distribution.
%
%% Approximation by Harmonic Expansion
%
% An approximation by harmonic expansion is computed by the command
% <SO3FunHarmonic.approximate.html |SO3FunHarmonic.approximate|> 

% SO3F = SO3Fun.interpolate(ori,S.values,'harmonic')
SO3F = SO3FunHarmonic.approximate(ori,S.values)
plot(SO3F,'sigma')


%%
% Note that |SO3FunHarmonic.approximate| does not aim at replicating the
% values exactly. In fact the relative error between given data and the
% function approximation is

norm(SO3F.eval(ori) - S.values) / norm(S.values)

%%
% The reason for this difference is that MTEX by default applies
% regularization. The default regularization parameter is $\lambda =
% 0.0001$. We can switch off regularization by setting this value to $0$.

SO3F = SO3FunHarmonic.approximate(ori,S.values,'regularization',0)

% the relative error
norm(SO3F.eval(ori) - S.values) / norm(S.values)

plot(SO3F,'sigma')

%%
% We observe that the relative error is much smaller, however the
% oscillatory behavior of the approximated function indicates overfitting.
% A more detailed discussion about choosing a good regularization parameter
% can be found in the section <HarmonicApproximationTheory.html harmonic
% approximation theory>.
%
% An alternative way of regularization is to reduce the harmonic bandwidth

SO3F = SO3FunHarmonic.approximate(ori,S.values,'bandwidth',16)

% the relative error
norm(SO3F.eval(ori) - S.values) / norm(S.values)

plot(SO3F,'sigma')

%%
% One big disadvantage of harmonic approximation is that the resulting
% function is not guarantied to be non negative, even if all given function
% values have been non negative.

min(SO3F)

%%
% This possibility to guaranty non negativity is the central advantage of
% kernel based approximation. 
%
%% Approximation by Radial Functions 
%
% The command for approximating orientation dependent data by a
% superposition of radial functions is <SO3FunRBF.approximate.html
% |SO3FunRBF.approximate|>. 

% SO3F = SO3Fun.interpolate(ori,val,'odf');
SO3F = SO3FunRBF.approximate(ori,S.values,'odf');

% the relative error
norm(SO3F.eval(ori) - S.values) / norm(S.values)

plot(SO3F,'sigma')

%%
% The option |'ODF'| ensures that the resulting function is nonnegative and
% is normalized to $1$

min(SO3F)

mean(SO3F)

%% 
% The key parameter when approximation by radial functions is the halfwidth
% of the kernel function. This can be set by the option |'halfwidth'|. A
% large halfwidth results in a very smooth approximating function whereas a
% very small halfwidth may result in overfitting

psi = SO3DeLaValleePoussinKernel('halfwidth',2.5*degree);
SO3F = SO3FunRBF.approximate(ori,S.values,'kernel',psi,'odf');

plot(SO3F,'sigma')

%%
% A more detailed discussion about the correct choice of the halfwidth and
% other options can be found in the section <RBFApproximationTheory.html
% theory of RBF approximation>.
%
%% 
% If we omit the option |'odf'| the resulting function may have negative
% values similar to the harmonic setting

SO3F = SO3FunRBF.approximate(ori,S.values);

% the relative error
norm(SO3F.eval(ori) - S.values) / norm(S.values)

plot(SO3F,'sigma')

%% Approximating using the Bingham distribution
%
% Approximation with the Bingham distribution currently works only with no
% symmetry. TODO!

cs = crystalSymmetry("1");

odf = fibreODF(fibre.rand(cs))

figure(1)
plot(odf)

%%

SO3F = SO3FunBingham.approximate(odf)

figure(2)
plot(SO3F)
