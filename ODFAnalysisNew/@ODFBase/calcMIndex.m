function MI = calcMIndex(odf)
% Computes the M-index from an odf - in contrast to using a discrete number
% of orientations (Skemer et al., 2005).
% The M-index is derived from the difference between
% uncorrelated and uniform misorientation angle distributions
%
% Reference
% Skemer, P., Katayama, I., Jiang, Z. & Karato, S.-I. (2005)
% The misorientation index: development of
% a new method for calculating the strength of latticepreferred
%
% Recommended read:
% Schaeben, H., (2007) Comment on “The misorientation index: Development 
% of a new method for calculating the strength of lattice-preferred 
% orientation” by Philip Skemer, Ikuo Katayama, Zhenting Jiang, Shun-ichiro Karato. 
% Tectonophysics 441, 115–117
%
% Reference for the computational method using MTEX
% Mainprice, D., Bachmann, F., Hielscher, R., Schaeben, H. (2014)
% Descriptive tools for the analysis of texture projects with
% large datasets using MTEX: strength, symmetry and components.
% In: Faulkner, D. R., Mariani, E. & Mecklenburgh, J. (eds)
% Rock Deformation from Field, Experiments and Theory:
% A Volume in Honour of Ernie Rutter. Geological Society, London,
% Special Publications, 409, http://dx.doi.org/10.1144/SP409.8
%
% Input
%  odf  -  @odf
%
% Output
%  M-index
%
% See also
% orientation/calcMIndex

% Step 1 : Uniform misorientation angle distribution for Crystal symmetry (CS)
[density_uniform,~] = calcAngleDistribution(odf.CS,odf.SS);

% normalize the misorientation angle distribution
density_uniform = density_uniform/sum(density_uniform);

% Step 2 : calculate the uncorrelated MDF from ODF
uncorrelated_MDF = calcMDF(odf);

% Step 3 : uncorrelated misorientation angle distribution from MDF
[uncorrelated_density_MDF,~] = calcAngleDistribution(uncorrelated_MDF,'resolution',1*degree);

% normalize the misorientation angle distribution
uncorrelated_density_MDF = uncorrelated_density_MDF/sum(uncorrelated_density_MDF);

% Step 4 : calculate the M-index
MI = (sum((abs(density_uniform - uncorrelated_density_MDF))/2));

end
