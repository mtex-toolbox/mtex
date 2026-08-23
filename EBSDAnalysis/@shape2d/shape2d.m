classdef shape2d < grain2d
% class representing a single closed shape in the plane
%
% A shape2d is a @grain2d consisting of exactly one grain, which makes
% every grain shape method - long axis, aspect ratio, equivalent radius,
% paror and surfor - available for an outline that did not come from a
% segmentation. This is what the characteristic shape of a boundary
% length distribution is returned as.
%
% Syntax
%   shape = shape2d(V)
%   shape = shape2d(V,cs)
%
% Input
%  V  - n x 2 list of vertices, or a @grainBoundary
%  cs - crystal @symmetry
%
% Output
%  shape - @shape2d
%
% Class Properties
%  Vs    - list of vertices
%  rho   - radius in polar coordinates
%  theta - angle in polar coordinates
%
% Example
%
%   mtexdata forsterite
%   grains = calcGrains(ebsd('indexed'));
%   shape = characteristicShape(grains.boundary('f','f'))
%
% See also
% grain2d calcTDF characteristicShape
%

  properties (Dependent=true)
    Vs      % list of vertices
    rho     % radius of polar coords
    theta   % angle of polar coords
  end


  % 1) should be constructed from calcTDF / circdensity (density function from a set of lines)
  % characteristicshape
  % surfor, paror
  % 2) purpose: take advantage of grain functions (long axis direction, aspect ratio..)
  %
  % additional functions I will try to put here: measure of asymmetry
  % nice plotting wrapper (replacing plotTDF)
  
  methods
    
    function shape = shape2d(V,CS)
      % list of vertices [x y]
      
      if nargin == 0, return;end

      N = size(V,1);
      shape.poly = {[1:N,1].'};
      shape.inclusionId = zeros(N,1);

      if nargin>=2
        shape.CSList = {CS};
      else
        shape.CSList = {'notIndexed'};
      end

      shape.phaseId = 1;
      shape.phaseMap = 1;
      shape.id = 1;
      shape.numPixel = 1;
      
      if isa(V,'grainBoundary') % grain boundary already given
        shape.boundary = V;
      else % otherwise compute grain boundary
                
        F = [1:N;[2:N 1]].';
        grainId = [zeros(N,1),ones(N,1)];
        
        % F is already the closed ring 1-2-...-N-1, and must not be ordered:
        % misrotation and ebsdId are scalars here, so it cannot survive a subSet
        shape.boundary = grainBoundary(V,F,grainId,1,...
          1,nan,shape.CSList,shape.phaseMap,1,'noTriplePoints','noOrder');
        
      end

    end

    function Vs = get.Vs(shape)
      Vs = shape.boundary.allV;
    end
    
    function theta = get.theta(shape)
      theta = angle(vector3d.X,shape.boundary.allV,shape.N);
    end
    
    function rho = get.rho(shape)
      rho = norm(shape.boundary.allV);
    end
  end
    
  methods (Static = true)
    shape = byRhoTheta(rho,theta)
    shape = byFV(F,V,varargin)
  end
  
end
