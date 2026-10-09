classdef meanFilter < EBSDFilter
  % implements a convolution filter for quaternions
  %
  % Replaces every orientation by the weighted mean of its neighbourhood.
  % The fastest filter, and the one that blurs boundaries most.
  %
  % Syntax
  %   F = meanFilter
  %   F = meanFilter('numNeighbours',2)
  %   F = meanFilter('weights',ones(3))
  %   ebsd = smooth(ebsd,F)
  %
  % Options
  %  numNeighbours - the pixels within that many steps to a side, 1 by default
  %  weights       - the convolution kernel, the pixel and its four neighbours by default
  %
  % Class Properties
  %  weights       - the convolution kernel
  %  numNeighbours - half the width of the kernel, the rings on a hexagonal grid
  %  isHex         - is the map on a hexagonal grid
  %
  % See also
  % EBSDFilter EBSD/smooth splineFilter
  %
  
  properties
    weights
  end
  
  properties (Dependent = true)
    numNeighbours
  end
  
  methods

    function F = meanFilter(varargin)      
      F.numNeighbours = get_option(varargin,'numNeighbours',1);
      F.weights = get_option(varargin,'weights',F.weights);
    end
    
    function n = get.numNeighbours(F)
      n = (length(F.weights)-1) / 2;
    end
    
    function set.numNeighbours(F,n)
      [i,j] = meshgrid(-n:n);
      F.weights = double(abs(i) + abs(j) <= n);
    end
    
    function plot(F)
      imagesc(F.weights)
    end
    
    function ori = smooth(F,ori,quality)

      % the tangent vectors at the mean, zero and weightless where nothing is measured
      [oriMean,ori] = mean(ori);
      tq = log(ori,oriMean,SO3TangentSpace.rightVector,'noSymmetry');
      w = quality .* ~isnan(tq.x);
      T = cat(3,tq.x,tq.y,tq.z);
      T(isnan(T)) = 0;

      % the sum over the window, nothing outside the map or the grain
      if F.isHex
        S = @hexSum; nPass = F.numNeighbours;
      else
        S = @(A) filter2(F.weights,A); nPass = 1;
      end

      % the weighted mean of the window, the mean orientation where it holds no measurement
      for j = 1:nPass
        den = S(w);
        den(den==0) = inf;
        for k = 1:3, T(:,:,k) = S(w.*T(:,:,k)) ./ den; end
      end

      ori = exp(oriMean,vector3d(T(:,:,1),T(:,:,2),T(:,:,3)),SO3TangentSpace.rightVector);

    end

  end
end


function A = hexSum(A)
% the sum over every pixel and its six neighbours on a hexagonal grid

% two rows of zero padding keep the parity of the rows
sz = size(A);
P = zeros(sz+[4 2]);
P(3:end-2,2:end-1) = A;
id = hexNeighbors(size(P));
P = P + sum(P(id),3);
A = P(3:end-2,2:end-1);

end
