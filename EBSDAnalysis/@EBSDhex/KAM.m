function kam = KAM(ebsd,varargin)
% intragranular average misorientation angle per orientation
%
% Syntax
%
%   plot(ebsd, ebsd.KAM ./ degree)
%
%   % ignore misorientation angles > threshold
%   kam = KAM(ebsd, 'threshold', 10*degree);
%   plot(ebsd,kam./degree)
%
%   % ignore grain boundary misorientations
%   [grains, ebsd.grainId] = calcGrains(ebsd)
%   plot(ebsd, ebsd.KAM./degree)
%
%   % consider also second order neigbors
%   kam = KAM(ebsd, 'order', 2);
%   plot(ebsd, kam./degree)
%
% Input
%  ebsd - @EBSDhex
%
% Options
%  threshold - ignore misorientation angles larger then threshold
%  order     - consider neighbors of order n
%  max       - take not the mean but the maximum misorientation angle
%
% See also
% grain2d.GOS

% ensure that we have not to deal with symmetry anymore
ebsd = ebsd.project2FundamentalRegion;

if check_option(varargin,'max')
  fun = @(a,b) nanmax(a,[],b);
else
  fun = @(a,b) nanplus(a,b);
end

% extract weights and order
weights = get_option(varargin,'weights',[]);

if isempty(weights)

  % get order
  order = get_option(varargin,'order',1);
  weights = ones(1,order);
  
else
  
  order = length(weigths);
  
end

% get threshold
threshold = get_option(varargin,'threshold',inf);
      
% prepare the result
kam = zeros(size(ebsd));

% for taking the mean count the non nan values
count = zeros(size(kam));

% extract rotations
rot = ebsd.rotations;

% for all distances
for radius = 1:order
  
  % for all points on the circle
  for k = 1:6*radius

    % compute neighbors
    indN = ebsd.neighbors(1:length(ebsd),k,radius);
    
    % for all phases
    for idPhase = ebsd.indexedPhasesId

      % ommit nan neighbors
      doInclude = ~isnan(indN);
      
      % consider only pixels of the same phase
      doInclude(doInclude) = ebsd.phaseId(doInclude) == idPhase;
      doInclude(doInclude) = ebsd.phaseId(indN(doInclude)) == idPhase;
      
      % avoid grain boundaries
      if isfield(ebsd.prop,'grainId')
        doInclude(doInclude) = ebsd.grainId(indN(doInclude)) == ebsd.grainId(doInclude);
      end      
      
      % compute misorientation angles
      omega = angle(rot(doInclude),rot(indN(doInclude)));
      
      % apply angle threshold
      omega(omega > threshold) = NaN;
      
      % update kam
      kam(doInclude) = fun(kam(doInclude), omega * weights(radius));
      count(doInclude) = fun(count(doInclude),~isnan(omega) .* weights(radius));
      
    end
  end

end
  
kam = kam ./ count;      
kam(count==0) = nan;
