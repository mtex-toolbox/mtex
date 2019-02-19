function m = calcMIndex(ori,varargin)
% Computes the M-index from a discrete number of orientations
% (Skemer et al., 2005).
% The M-index is derived from the difference between
% uncorrelated and uniform misorientation angle distributions
%
% Reference
% Skemer, P., Katayama, I., Jiang, Z. & Karato, S.-I. (2005)
% The misorientation index: development of
% a new method for calculating the strength of lattice preferred
% orientation. Tectonophysics, 411, 157-167.
% 
% Recommended read:
% Schaeben, H., (2007) Comment on “The misorientation index: Development 
% of a new method for calculating the strength of lattice-preferred 
% orientation” by Philip Skemer, Ikuo Katayama, Zhenting Jiang, Shun-ichiro Karato. 
% Tectonophysics 441, 115–117.
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
%  ori  -  @orientation
%
% Output
%  M-index
%
% See also
% odf/calcMIndex

%
if ~isa(ori.SS,'crystalSymmetry') % check if input is a misorientation
    % derive some uncorrelated misorientations
    if length(ori)>1e4
    ori = inv(ori).*subSet(ori,randperm(length(ori)));
    else
    ori = reshape(inv(ori)*subSet(ori,randperm(length(ori))),[],1);
    end
end

% experimental angle distribution
[RO,theta] = calcAngleDistribution(ori);
RO = RO ./ mean(RO);

% theoretic angle distribution
RT = calcAngleDistribution(ori.CS,ori.SS,theta);
RT = RT(:) ./ mean(RT);

m = 0.5 * mean(abs(RT-RO));
end

