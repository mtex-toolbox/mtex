classdef gbcFMC < grainBoundaryCriterion
% gbcFMC  fast multiscale clustering (FMC) grain boundary criterion
%
% Wraps the FMC algorithm (McMahon et al.). Unlike the local criteria this one
% clusters the whole neighbourhood graph at once; doEvaluate therefore builds
% the adjacency from (i,j), runs FMC, and reports for each pair whether both
% endpoints ended up in the same (non-zero) cluster.
%
% Syntax
%
%   criterion = gbcFMC(cmaha);
%   criterion = gbcFMC('cmaha',3,'beta',0.3);
%   out = criterion.eval(ebsd,i,j);
%
% Output
%   out = 1   same cluster (same grain)
%   out = 0   grain boundary
%
% Options (defaults in brackets)
%   cmaha   - Mahalanobis threshold
%   cmaha0  - lower misorientation bias (0.05)
%   quatmax - quaternion variance metric for cluster (5)
%   alpha   - seed selection (0.2)
%   beta    - probability threshold for point in cluster (0.3)
%   gammaW  - edge dilution (25)

properties
  cmaha   = 3
  cmaha0  = 0.05
  quatmax = 5
  alpha   = 0.2
  beta    = 0.3
  gammaW  = 25
end

methods

  function obj = gbcFMC(varargin)
    if nargin >= 1 && isnumeric(varargin{1}) && ~isempty(varargin{1})
      obj.cmaha = varargin{1}(1);
    else
      obj.cmaha = get_option(varargin,{'fmc','cmaha'},obj.cmaha,'double');
    end
    obj.cmaha0  = get_option(varargin,{'cmaha0'}, obj.cmaha0, 'double');
    obj.quatmax = get_option(varargin,{'quatmax'},obj.quatmax,'double');
    obj.gammaW  = get_option(varargin,{'gammaW'}, obj.gammaW, 'double');
    obj.alpha   = get_option(varargin,{'alpha'},  obj.alpha,  'double');
    obj.beta    = get_option(varargin,{'beta'},   obj.beta,   'double');
  end

end

methods (Access = protected)

  function out = doEvaluate(obj,ebsd,i,j)

    q  = ebsd.rotations;
    CS = ebsd.CSList(ebsd.indexedPhasesId(1));   % primary indexed phase

    A_D = sparse(double(i),double(j),true,length(q),length(q));

    fmc.CS = CS;
    fmc.O  = q;

    fmc.cmaha    = obj.cmaha;
    fmc.cmaha0   = obj.cmaha0;
    fmc.quatmax  = obj.quatmax;
    fmc.quatmax2 = cos(obj.quatmax/2*degree);
    fmc.gammaW   = obj.gammaW;
    fmc.alpha    = obj.alpha;
    fmc.beta     = obj.beta;
    fmc.A_D      = A_D;

    [AllPs,AllSals,numClusters] = FMC_MTEX(fmc);
    assignments = FMC_interpret(AllSals, numClusters, AllPs, A_D, fmc.beta);

    out = double(assignments(i,1) == assignments(j,1) & assignments(i,1) > 0);
    out = reshape(out,size(i));
  end

end

end