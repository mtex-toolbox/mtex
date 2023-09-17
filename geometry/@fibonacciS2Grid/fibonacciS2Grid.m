classdef fibonacciS2Grid < vector3d
  % The class fibonacciS2Grid creates equispaced grids on the sphere by placing
  % points around a spiral around the sphere. The class also provies a
  % method to find grid points around a given center with specified radius.
  %
  % Syntax
  % fibgrid = fibonacciS2Grid(N)
  % fibgrid = fibonacciS2Grid('points', N)
  % fibgrid = fibonacciS2Grid('resolution', res*degree)
  %
  % Input
  % N - number of points
  % res - resolution of the grid 
  %
  % Options
  % points - number of points to be generated
  % res    - desired resolution of the grid
  %
  % Class Properties
  % inherited from vector3d
 
  % the dependent properties that are commented could be useful for finding
  % neighbors in large grids
  properties (Dependent = true)
    filldist    % fill distance (radius of biggest hole)
    sepdist     % separation distance (half of smallest distance between nodes)
    maxsep      % maximal separation between two nodes
    % rho_sorted  % azimuth angles in ascending order from 0 to 2*pi
    % sortidx     % index vector such that rho_sorted = rho(sortidx)
    % revidx      % index vector such that revidx(i) is index of rho in rho_sorted
    % rhodiff_max % maximal difference between neighbors in rho_sorted
  end

  methods
    % constructor of the class fibonacciS2Grid
    function fibgrid = fibonacciS2Grid(varargin)
      % define the golden ratio
      phi = (1+sqrt(5)) / 2;
      if (nargin==1) 
        n = round((varargin{1}-1)/2);
      elseif (nargin==2) 
        if check_option(varargin, 'points')
          n = round((varargin{2}-1) / 2);
        elseif check_option(varargin, 'resolution')
          res = varargin{2};
          % this comes from fitting the grid sizes to the resolutions
          n = round((exp(2.512) / res^2 - 1) / 2);
        end
      else
        n = 1000;
      end
      % doing it in reverse results in incresing theta anlge
      idx = (n : -1 : -n)';
      rho = mod(2*pi/phi * idx, 2*pi);
      sintheta = 2/(2*n+1) * idx;
      costheta = sqrt(1 - sintheta.^2);
      fibgrid.x = cos(rho) .* costheta;
      fibgrid.y = sin(rho) .* costheta;
      fibgrid.z = sintheta;
    end

    % getters
    function filldist = get.filldist(fibgrid)
      randvec = vector3d.rand(10000);
      [~, d] = fibgrid.find(randvec);
      filldist = max(d);
    end

    function sepdist = get.sepdist(fibgrid)
      % this guarantees that at least one neighbor is in the delta
      % region around v
      delta = acos(1 - 3.5 * 2 / numel(fibgrid.x));
      % the smallest separation always occurs at the first and last
      % grid point (closest to pole)
      [~,~,~,dist] = fibgrid.find(fibgrid.subSet(numel(fibgrid.x)), delta);
      sortdist = sort(dist);
      sepdist = sortdist(2) / 2;
    end

    function maxsep = get.maxsep(fibgrid)
      % the biggest separation always occurs on the (n+1)-th grid
      % point (one the equator at (1,0,0))
      delta = acos(1 - 3.5 * 2 / numel(fibgrid.x));
      [~,~,~,dist] = fibgrid.find(vector3d.X, delta);
      sortdist = sort(dist);
      maxsep = sortdist(2);
    end

    function varargout = find(fibgrid, v, varargin)
      if nargin == 2
        % varargout is [grid_idx distances]
        if numel(fibgrid.x) < 2e7
          [ind, dist] = fibonacciS2Grid_find(fibgrid, v);
        else
          [ind, dist] = fibonacciS2Grid_findbig(fibgrid, v);
        end
        varargout{1} = ind;
        varargout{2} = dist;
      elseif nargin == 3
        % varargout is [grid_idx test_idx num_neighbors distances]
        epsilon = varargin{1};
        if numel(fibgrid.x) < 2e7
          [g_id, t_id, nn, dist] = ...
            fibonacciS2Grid_find_region(fibgrid, v, epsilon);
        else
          [g_id, t_id, nn, dist] = ...
            fibonacciS2Grid_findbig_region(fibgrid, v, epsilon);
        end
        varargout{1} = g_id;
        varargout{2} = t_id;
        varargout{3} = nn;
        varargout{4} = dist;
      end
    end
  end
end