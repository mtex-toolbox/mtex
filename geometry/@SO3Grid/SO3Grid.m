classdef (InferiorClasses = {?rotation,?quaternion}) SO3Grid < orientation
%  
% Syntax
%  S3G = SO3Grid(nodes,CS,SS)
%  S3G = SO3Grid(points,CS,SS)
%  S3G = SO3Grid(resolution,CS,SS)
%
% Input
%  points     - number of nodes
%  nodes      - @quaternion
%  resolution - double
%  CS, SS     - @symmetry groups
%
% Options
%  regular    - construct a regular grid
%  equispaced - construct a equispaced grid%
%  phi        - use phi
%  ZXZ, Bunge - Bunge (phi1 Phi phi2) convention
%  ZYZ, ABG   - Matthies (alpha beta gamma) convention
%  maxAngle   - only up to maximum rotational angle
%  center     - with respect to this given center

  
  properties
    alphabeta = [];
    gamma    = [];
    resolution = 2*pi;
    center  = [];
  end
  
  methods
    function S3G = SO3Grid(ori,alphabeta,gamma,varargin)
      
      % call superclass method
      S3G = S3G@orientation(ori);

      S3G.alphabeta = alphabeta;
      S3G.gamma = gamma;
      S3G.center = get_option(varargin,'center',quaternion.id);
      S3G.resolution = get_option(varargin,'resolution',2*pi);
    end
  end
end
