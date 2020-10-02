function kam = KAM(ebsd,varargin)
% intragranular average misorientation angle per orientation
%
% Syntax
%
%   plot(ebsd,ebsd.KAM ./ degree)
%
%   % ignore misorientation angles > threshold
%   kam = KAM(ebsd,'threshold',10*degree);
%   plot(ebsd,kam./degree)
%
%   % ignore grain boundary misorientations
%   [grains, ebsd.grainId] = calcGrains(ebsd)
%   plot(ebsd, ebsd.KAM./degree)
%
%   % consider also second order neigbors
%   kam = KAM(ebsd,'order',2);
%   plot(ebsd,kam./degree)
%
% Input
%  ebsd - @EBSD
%
% Options
%  threshold - ignore misorientation angles larger then threshold
%  order     - consider neighbors of order n
%  max       - take not the mean but the maximum misorientation angle
%
% See also
% grain2d.GOS


%weights = get_option(varargin,'weights',ones(3));

if check_option(varargin,'max')
  fun = @(a,b) nanmax(a,[],b);
else
  fun = @(a,b) nanplus(a,b);
end

weights = get_option(varargin,'weights',[]);

if isempty(weights)

  % get order
  order = get_option(varargin,'order',1);
  [i,j] = meshgrid(-order:order,-order:order);
  weights = (abs(i) + abs(j)) <= order;

  psi = get_option(varargin,'kernel');
  if ~isempty(psi)
    weights = psi(sqrt(ebsd.dy^2 * i.^2 + ebsd.dx^2 * j.^2));
  end
else
  
  order = (min(size(weights)) -1)/2;
  
end

% set center to zero
weights(order+1,order+1) = 0;

% get threshold
threshold = get_option(varargin,'threshold',inf);
      
% prepare the result
kam = zeros(size(ebsd));

% for taking the mean count the non nan values
count = zeros(size(kam));

% extract grainIds and make them a bit larger
if isfield(ebsd.prop,'grainId')
  grainId = nan(size(ebsd)+2*order);
  grainId(order+1:end-order,order+1:end-order) = ebsd.grainId;
end

% for all phases
for id = ebsd.indexedPhasesId

  
  % extract orientations and make them a bit larger
  rot = ebsd.rotations;
  rot(ebsd.phaseId ~= id) = NaN;
  ori = orientation.nan(size(ebsd)+2*order,ebsd.CSList{id});
  ori(order+1:end-order,order+1:end-order) = rot;
  
  % take the mean
  for i = -order:order
    for j = -order:order
      
      if  weights(order+1+i,order+1+j) == 0, continue; end
      
      % compute misorientation angles
      omega = angle(ori(order+1:end-order,order+1:end-order),...
        ori((order+1:end-order)+i,(order+1:end-order)+j));
      
      % apply angle threshold
      omega(omega > threshold) = NaN;
      
      % avoid grain boundaries
      if isfield(ebsd.prop,'grainId')
        omega( grainId(order+1:end-order,order+1:end-order) ~= ...
          grainId((order+1:end-order)+i,(order+1:end-order)+j) ) = NaN;
      end
      
      kam = fun(kam, omega .* weights(order+1+i,order+1+j));
      count = fun(count,~isnan(omega) .* weights(order+1+i,order+1+j));
      
    end
  end

end
  
kam = kam ./ count;
      
