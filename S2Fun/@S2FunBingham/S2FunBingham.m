classdef S2FunBingham < S2Fun
% a class representing a spherical Bingham distribution
%
% The Bingham distribution is the antipodal analogue of a Gaussian on the
% sphere. Its shape parameters Z, sorted decreasingly with Z(3) < 0, run
% from a rotationally symmetric unimodal distribution for Z(1) = Z(2) to a
% girdle distribution for Z(1) << Z(2).
%
% Syntax
%   BS2 = S2FunBingham(Z)
%   BS2 = S2FunBingham(Z,a)
%   BS2 = S2FunBingham(Z,a,cs)
%
% Input
%  Z  - shape parameters, Z(1) >= Z(2) >= Z(3), Z(3) < 0
%  a  - principal axes, @vector3d, default are the coordinate axes
%  cs - @symmetry or @referenceFrame the distribution is expressed in
%
% Output
%  BS2 - @S2FunBingham
%
% Class Properties
%  a         - principal axes, @vector3d
%  Z         - shape parameters
%  N         - normalization constant
%  antipodal - always true
%
% Example
%
%   BS2 = S2FunBingham([-10 -10 -20])
%
% See also
% S2Fun S2FunHarmonic

  properties
    a  % principle axes
    Z  % smoothing parameters
    isReal = 1;
  end
  
  properties (SetAccess=protected)
    N = 1   % normalization constant
    antipodal = 1
  end
  
  
  methods
    function BS2 = S2FunBingham(Z,a,sym)
      %
      % Description
      %  defines a spherical Bingham distribution with shape parameters |Z|
      %  and principal axes |a|. 
      %  Z(1)>=Z(2)>=Z(3), Z(3)<0
      %  Z(1)=Z(2)  rotationally symmetric unimodal distribution
      %  Z(1)<<Z(2) partial girdle distribution
      %
      % Syntax
      %
      %   BS2 = S2FunBingham(Z,a)
      %
      % Input
      %  Z -  shape parameters
      %  a -  principle axes @vector3d
      %
      % Output
      %  BS2 - @S2FunBingham (spherical Bingham distribution)
      
      BS2.Z = Z;
      
      if nargin == 1
        BS2.a = [vector3d.X;vector3d.Y;vector3d.Z];
      else
        BS2.a = a.normalize;
      end

      if nargin > 2
        BS2.framePrivate = S2Fun.extractFrame(sym);
      end
      
      % compute normalization constant
      BS2.N = 4*pi./BS2.normalizationConst;
    end
    
    
    function value = eval(BS2,v)
      % evaluate spherical Bingham distribution
      value = BS2.N * exp(dot_outer(v.normalize,BS2.a).^2 * BS2.Z(:));
    end
    
    
    function N = normalizationConst(BS2)   % needs external mex
      %   calc normalization parameter
      N = numericalSaddlepointWithDerivatives(double(sort(-BS2.Z(:))+1))*exp(1);
      N = N(3);
    end
    
  end
  
  methods (Static = true)
    
    [BS2,ab,rot] = fit(v,varargin)
    BS2 = example(varargin)
    
  end
end
