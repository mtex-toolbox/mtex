function varargout = onGrid(ebsd,fun,varargin)
% run a matrix algorithm on an EBSD and hand the result back in its own shape
%
% Some algorithms are genuinely 2d raster algorithms - a filter over a
% window, a morphological operation - and need the data as a matrix. They
% used to call gridify themselves, which changed the caller's class, and
% returned results shaped like the grid rather than like the input. This
% wraps that: gridify, run, map back.
%
% Syntax
%   out = onGrid(ebsd,fun)
%   [o1,o2] = onGrid(ebsd,fun,'grid',{'unitCell',uC})
%
% Input
%  ebsd - @EBSD, gridded or not
%  fun  - @(ebsdGrid) [r1,r2,...]
%
% Output
%  oK - rK expressed in the input's shape and class
%
% Options
%  grid     - cell of flags forwarded to gridify
%  keepGrid - return the gridded results untouched
%
% Description
% How a result is mapped back depends on what it is, and the two cases are
% genuinely different rather than two spellings of one rule:
%
%  * an @EBSD keeps the caller's class - a gridded map stays gridded. A
%    plain one goes through the copy constructor, which keeps every real
%    measurement and drops the notIndexed sites gridify added as padding.
%    That INCLUDES pixels the callback filled in, so a denoising run with
%    'fill' still returns more pixels than it was given - the row count is
%    not preserved, and must not be.
%  * anything else with one entry per pixel - a @vector3d, a double, a
%    @tensor - IS row aligned, so it is indexed by the newId gridify
%    returns and reshaped to the caller's shape.
%  * anything else passes through untouched, since there is nothing to
%    map: smooth's second output is the filter it used, not pixel data.
%
% See also
% EBSD/gridify EBSD/smooth EBSD/weightedBurgersVec

gridOpt = get_option(varargin,'grid',{});
keepGrid = check_option(varargin,'keepGrid');
wasGrid = isa(ebsd,'EBSDgrid');

% already a grid and nothing to re-grid: nothing to do either
if wasGrid && isempty(gridOpt)
  [varargout{1:nargout}] = fun(ebsd);
  return
end

[eG,newId] = ebsd.gridify(gridOpt{:});

res = cell(1,nargout);
[res{1:nargout}] = fun(eG);

varargout = cell(1,nargout);
for k = 1:nargout

  r = res{k};

  if keepGrid
    varargout{k} = r;
  elseif isa(r,'EBSD')
    % the caller's class, not gridify's: a gridded map stays gridded
    if wasGrid, varargout{k} = r; else, varargout{k} = EBSD(r); end
  elseif numel(r) == length(eG)
    varargout{k} = reshape(r(newId),size(ebsd));
  else
    % not a per pixel result at all - smooth hands back the filter it
    % used - so there is nothing to map and it passes through
    varargout{k} = r;
  end

end

end
