function [traces, rel, cSize] = calcTraces(grains, clusterId, varargin)
% traces of subsets of grains
%
% Syntax
%
%   clusterId = [grainId,variantId];
%   [traces, rel, cSize] = calcTraces(grains, clusterId,'shape')
%
% Input
%  grains - @grain2d
%  cId  - cluster Id
%
% Output
%  traces - @vector3d, size max(clusterId(:,1)) x max(clusterId(:,2)) ....
%  rel    - relyability index, same size as traces
%  cSize  - cluster size, , same size as traces
%
% Options
%  minClusterSize - minimum grainSize required for trace computation (default: 100)
%  shape - characteristic shape based algorithm
%  calliper - use shortest calliper instead of eigenvectors
%  hist  - circular histogram based algorithm
%
% References
%
% * <https://arxiv.org/abs/2201.02103 Determination of child phase habit
% planes from two-dimensional reconstructed parent phase orientation maps>,
% arXiv, 2022
%

% generate clusters
if nargin == 1 || ~isnumeric(clusterId), clusterId = ones(length(grains),1); end
notZero = all(clusterId>0,2);
cSize = accumarray(clusterId(notZero,:),grains.grainSize(notZero));
ic = find(cSize > get_option(varargin,'minClusterSize',100));

% prepare output
sz = [max(clusterId),1];
omega = nan(sz);
rel = zeros(sz);

% extract grain geometry
rot = grains.rot2Plane;
V = rot .* grains.boundary.allV;
V = V.xyz;
F = grains.boundary.F;
I_BG = grains.boundary.I_FG;
grainId = grains.id;

% get method to use
useHist = check_option(varargin,'hist');
useCalliper = check_option(varargin,'calliper');

% loop over all relevant clusters
for i = 1:length(ic)

  % combine grains according to clusterIndex
  [sub{1:size(clusterId,2)}]  = ind2sub(sz,ic(i));
  ind = all(clusterId == [sub{:}],2);
    
  % the boundary segments
  lF = F(any(I_BG(:,grainId(ind)),2),:);

  % shifted into the origin
  lS = V(lF(:,1),:) - V(lF(:,2),:);

  if isempty(lF), continue; end

  if useHist % density function method

    rho = atan2(lS(:,2),lS(:,1));
  
    %fun = calcDensity(rho, 'weights',sqrt(sum(lS.^2,2)),'periodic','sigma',10*degree);
    fun = calcDensity(rho, 'weights',vecnorm(lS,2,2),'periodic','sigma',10*degree);
    fun.antipodal = true;

    phi = linspace(0,2*pi,360);
    [m,ind] = max(real(fun.eval(phi)));
    
    omega(ic(i)) = phi(ind);
    rel(ic(i)) = (m-1)/m;

  else % characteristic shape method
    
    %cS = shape2d.byFV(F(any(I_BG(:,ind),2),:),V,'noSimplify');
    %[omega(ic(i)),a,b] = principalComponents(cS);
    %traces(ic(i)) = cS.caliper('shortestPerp'); % this is a bit more precise but slower

    % the following lines are from shape2d.byFV
    % just consider one direction
    fcond = lS(:,2)<0;
    lS(fcond,:)=lS(fcond,:).*-1;
    dxy = [lS; -lS];

    % sort segments according to angle
    [~,id]= sort(atan2(dxy(:,2),dxy(:,1)));
    dxy = dxy(id,:);

    % sum up
    xyn = cumsum(dxy);

    % shift again
    xyn = [xyn(:,1) - mean(xyn(:,1)) xyn(:,2) - mean(xyn(:,2))];
    
    if useCalliper
      
      mid = round(size(xyn,1)/2);
      dxyn = xyn - [xyn(1+mid:end,:);xyn(1:mid,:)];
      delta = vecnorm(dxyn,2,2);

      % minimum and maximum Ferret diameter
      a = max(delta); [b,ib] = min(delta);
    
      % use vector perpendicular to short axis
      omega(ic(i)) = pi/2 + atan2(dxyn(ib,2),dxyn(ib,1));
      
    else
    
      % the following lines are taken from grain2d/principleComponent
      % compute length of line segments
      dist = sqrt(sum((xyn(1:end-1,:) - xyn(2:end,:)).^2,2));
      dist = 0.5*(dist(1:end) + [dist(end);dist(1:end-1)]);
     
      % weight vertices according to half the length of the adjacent faces
      xyn = xyn(1:end-1,:) .* [dist,dist] .* sum(xyn(1:end-1,:).^2,2).^(0.25);
      
      % compute eigen values and vectors
      [ew, omega(ic(i))] = eig2(xyn' * xyn);
    
      % halfaxes are square roots of the eigenvalues
      b = sqrt(ew(1)); a = sqrt(ew(2));
    end
    rel(ic(i)) = (a-b)./a;
  end

end

traces = inv(rot) .* vector3d.byPolar(pi/2,omega,'antipodal');
