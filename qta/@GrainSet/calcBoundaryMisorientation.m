function mori = calcBoundaryMisorientation(grains1,varargin)
% calculate misorientation at grain boundaries
%
%% Input 
% grains - @GrainSet
%% Flags
% subboundary - only consider grain boundaries within a grain
% external - only consider grain boundaries closing a grain
%
%% Output
% m - @orientation, such that
%
%    $$m = (g{_i}^{--1}*CS^{--1}) * (CS *\circ g_j)$$
%
%   for two neighbored orientations $g_i, g_j$ with crystal @symmetry $CS$ of 
%   the same phase located on a grain boundary.
%
%% See also
% GrainSet/calcMisorientation GrainSet/plotAngleDistribution

%% get input
% check whether another grain set is present
ind = cellfun(@(c) isa(c,'GrainSet'),varargin);
if any(ind)
  grains2 = varargin{find(ind,1)};
else
  grains2 = grains1;
end

checkSinglePhase(grains1);
checkSinglePhase(grains2);

%% select the right boundaries
if check_option(varargin,{'sub','subboundary','internal','intern'})
  I_FD1 = logical(grains1.I_FDsub);
  I_FD2 = logical(grains2.I_FDsub);
elseif  check_option(varargin,{'external','ext','extern'})
  I_FD1 = logical(grains1.I_FDext);
  I_FD2 = logical(grains2.I_FDext);
else % otherwise select all boundaries
  I_FD1 = grains1.I_FDext | grains1.I_FDsub;
  I_FD2 = grains2.I_FDext | grains2.I_FDsub;
end

%% find adjacent voronoi cells
if any(ind) && grains1 ~= grains2
  [Dl,dummy] = find(I_FD1(sum(I_FD1,2) >= 1 & sum(I_FD2,2) >= 1,...
    any(grains1.I_DG,2))'); %#ok<NASGU>

  [Dr,dummy] = find(I_FD2(sum(I_FD1,2) >= 1 & sum(I_FD2,2) >= 1,...
    any(grains2.I_DG,2))'); %#ok<NASGU>
else
  [D,dummy] = find(I_FD1(sum(I_FD1,2) == 2,any(grains1.I_DG,2))'); %#ok<NASGU>
  Dl = D(1:2:end);
  Dr = D(2:2:end);
end
  
%% compute length of the common boundary of the adjacent vornoi cells
% TODO
  
%% subsample

if check_option(varargin,'SampleSize')
  sampleSize = get_option(varargin,'SampleSize');
  if sampleSize < numel(Dl)
    ind = discretesample(numel(Dl),sampleSize);
    Dl = Dl(ind);
    Dr = Dr(ind);
  end
end

%% compute misorienations
if numel(Dl) >0
    
  ol = get(grains1.EBSD,'orientations');
  or = get(grains2.EBSD,'orientations');
  mori = ol(Dl).\or(Dr);
  
else
  
  warning('selected phase does not contain any boundaries') %#ok<WNTAG>
  mori = orientation;
  
end


