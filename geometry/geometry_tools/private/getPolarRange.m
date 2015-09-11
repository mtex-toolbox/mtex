function bounds = getPolarRange(varargin)
% extract polar range for several S2Grids
%
% fundamental region 
% bound.FR = {minTheta,maxTheta,minRho,maxRho}
%
% region of vectors
% bound.VR  = {minTheta,maxTheta,minRho,maxRho}
%

% set up fundamental region
bounds.FR = {0,pi,0,2*pi};

bounds.VR{3} = get_option(varargin,'minRho',bounds.FR{3});
bounds.VR{4} = get_option(varargin,'maxRho',bounds.FR{4});

if check_option(varargin,'lower')
  bounds.FR(1:2) = {pi/2,pi};  
else
  bounds.FR{1} = 0;
  
  if check_option(varargin,{'antipodal','upper'}) && ...
      (~check_option(varargin,'complete') || check_option(varargin,'upper'))
    bounds.FR{2} = pi/2;
  else
    bounds.FR{2} = pi;
  end
end

% set up region of vectors
bounds.VR{1} = max(get_option(varargin,'minTheta',bounds.FR{1}),bounds.FR{1});
bounds.VR{2} = get_option(varargin,'maxTheta',bounds.FR{2});

% update maxTheta to respect maxTheta of VR
if ~isnumeric(bounds.VR{2})
 maxThetaFun = @(rho) min(bounds.VR{2}(rho),bounds.FR{2});
  bounds.VR{2} = max(maxThetaFun(...
    linspace(bounds.VR{3},bounds.VR{4},5)));
else
  bounds.VR{2} = min(bounds.VR{2},bounds.FR{2});
end

bounds.dtheta = bounds.VR{2} - bounds.VR{1};
bounds.drho = bounds.VR{4} - bounds.VR{3};

% resrict theta and rho range
if check_option(varargin,'restrict2MinMax'), bounds.FR = bounds.VR; end

% number of points and resolution
if check_option(varargin,'points')
  bounds.points = get_option(varargin,'points');
  if length(bounds.points) == 1
    bounds.res = sqrt(bounds.drho * bounds.dtheta/bounds.points);
    bounds.res = bounds.dtheta/round(bounds.dtheta/bounds.res);
    bounds.points = round([bounds.drho/bounds.res,bounds.dtheta/bounds.res]);
  end
else
  bounds.res = get_option(varargin,'resolution',...
    5*degree ./ (1+check_option(varargin,'plot')));
  if length(bounds.res) == 1
    bounds.res = [bounds.res bounds.res];
  end
  bounds.points = ceil([bounds.drho / bounds.res(1),bounds.dtheta / bounds.res(2) + 1]);
end



% final resolution
bounds.res = min(bounds.dtheta/(bounds.points(2)-1),...
  bounds.drho/bounds.points(1));
