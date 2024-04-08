classdef fibonacciS2Grid < vector3d
  % The class fibonacciS2Grid creates equispaced grids on the sphere by
  % placing points around a spiral around the sphere. The class also
  % provides a method to find grid points around a given center with
  % specified radius.
  %
  % Syntax
  %   fibgrid = fibonacciS2Grid(N)
  %   fibgrid = fibonacciS2Grid('points', N)
  %   fibgrid = fibonacciS2Grid('resolution', res*degree)
  %   % saves the precise rho angles in the options
  %   fibgrid = fibonacciS2Grid('points', N, 'saverho') 
  %
  % Input
  %  N - number of points
  %  res - resolution of the grid 
  %
  % Options
  %  points - number of points to be generated
  %  res    - desired resolution of the grid
  %
   
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
      saverho = false;
      % check if we should save the precise rho angles of the grid
      saverho_specifier_pos = find(strcmp(varargin, 'saverho'), 1);
      if ~isempty(saverho_specifier_pos)
        saverho = true;
        varargin(saverho_specifier_pos) = [];
      end

      % standard grid size is 1000
      if nargin > 0 && isnumeric(varargin{1})        
        numPoints = varargin{1};
      elseif check_option(varargin,'points')
        numPoints = get_option(varargin,'points');
      else
        res = get_option(varargin,'resolution',5*degree);        
        % this comes from fitting the grid sizes to the resolutions
        numPoints = exp(2.512) / res^2;        
      end

      n = round((numPoints - 1) / 2);

      % define the golden ratio
      phi = (1+sqrt(5)) / 2;
      
      % doing it in reverse results in incresing theta anlge
      idx = (n : -1 : -n)';
      rho = mod(2*pi/phi * idx, 2*pi); 
      sintheta = 2/(2*n+1) * idx;
      costheta = sqrt(1 - sintheta.^2);
      fibgrid.x = cos(rho) .* costheta;
      fibgrid.y = sin(rho) .* costheta;
      fibgrid.z = sintheta;
      if saverho
        fibgrid.opt.rho = mod(rho, 2*pi);
      end
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