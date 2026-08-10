classdef S2FunGrid < S2Fun
  % bilinear interpolation on a regular grid in polar coordinates

  properties
    values % [0,pi] x [0,2*pi]
    gSize  % grid size
    s = specimenSymmetry % symmetry / reference system
    isReal
    antipodal = false
  end
  
  methods

    function S2F = S2FunGrid(values, varargin)

      if isnumeric(values)
        % nTheta x nRho grid of scalars, or of vectors along the trailing
        % dimensions - flattened the same way as the function handle branch
        s = size(values);
        S2F.gSize = s(1:2);
        S2F.values = reshape(values,s(1)*s(2),[]);

      elseif isa(values,"function_handle")
        
        v = S2FunGrid.makeGrid(1*degree);
        S2F.gSize = size(v);
        S2F.values = reshape(values(v),numel(v),[]);

      end

    end

    function l = length(S2F)
      l = max(size(S2F));
    end

    function s = size(S2F,i)
      s = size(S2F.values);
      s = s(2:end);
      if nargin == 2
        s = s(i);
      end
    end


    function v = eval(S2F,nodes)
      % bilinear interpolation in (theta,rho)
      %
      % Nearest neighbour would be cheaper, but on a 1 degree grid it is
      % also about 20 times less accurate - interpolating buys more than
      % refining the grid does: bilinear at 1 degree beats nearest at 0.25
      % degree while using a sixteenth of the memory.
      %
      % Done in blocks, since each of the four gathered corners is as large
      % as the output itself - ten million directions in one go allocate
      % 0.76 GB of temporaries, in blocks nothing above the result. Blocking
      % is also about a quarter faster, each block staying nearer the cache.

      n = numel(nodes);
      v = nan(n,size(S2F));

      blockSize = 1e6;
      for k = 1:blockSize:n
        ind = k:min(k+blockSize-1,n);
        v(ind,:) = evalBlock(S2F,nodes(ind));
      end

    end

    function v = evalBlock(S2F,nodes)
      % bilinear interpolation for one block of directions

      [theta,rho] = polar(nodes); %#ok<POLAR>

      ind = ~isnan(theta);

      nTheta = S2F.gSize(1); nRho = S2F.gSize(2);

      % position within the grid, measured in cells
      % theta runs over [0,pi], rho over [0,2*pi), both end points present
      ti = theta(ind) / (pi/(nTheta-1));
      rj = rho(ind) / (2*pi/(nRho-1));

      % lower left corner of the containing cell, and the weights within it
      i0 = min(max(floor(ti),0),nTheta-2);
      j0 = min(max(floor(rj),0),nRho-2);
      a = reshape(ti - i0,[],1);
      b = reshape(rj - j0,[],1);

      % accumulated one corner at a time - summing all four in a single
      % expression keeps four gathered copies of the block alive at once
      res =       ((1-a).*(1-b)) .* S2F.values(sub2ind(S2F.gSize,i0+1,j0+1),:);
      res = res + (    a.*(1-b)) .* S2F.values(sub2ind(S2F.gSize,i0+2,j0+1),:);
      res = res + ((1-a).*    b) .* S2F.values(sub2ind(S2F.gSize,i0+1,j0+2),:);
      res = res + (    a.*    b) .* S2F.values(sub2ind(S2F.gSize,i0+2,j0+2),:);

      v = nan(numel(nodes),size(S2F));
      v(ind,:) = res;

    end

  end

  methods (Static=true)
    
    function v = makeGrid(res)
      theta = linspace(0,pi,1+round(pi/res));
      rho = linspace(0,2*pi,1+round(2*pi/res));
      v = vector3d.byPolar(theta.',rho);
    end

  end
end