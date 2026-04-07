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
  end

  methods
    % constructor of the class fibonacciS2Grid
    function fibgrid = fibonacciS2Grid(varargin)
      
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
      
      % doing it in reverse results in increasing theta angle
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
      filldist = fibgrid.compute_filldist();
    end

    function sepdist = get.sepdist(fibgrid)
      sepdist = fibgrid.compute_sepdist();
    end

    % compute functions for the getters
    function filldist = compute_filldist(fibgrid, varargin)
      randvec = vector3d.rand(1e4);
      [~, d] = fibgrid.find(randvec);
      if check_option(varargin, 'mean')
        filldist = mean(d);
      else
        filldist = max(d);
      end
    end

    function sepdist = compute_sepdist(fibgrid, varargin)
      [~, dist] = fibgrid.find(fibgrid, 2);
      if check_option(varargin, 'mean')
        sepdist = mean(dist(:,2));
      elseif check_option(varargin, 'max')
        sepdist = max(dist(:,2));
      else
        sepdist = min(dist(:,2));
      end
    end

  end
end
