classdef (InferiorClasses = {?rotation,?quaternion}) SO3Grid < orientation
% represent orientations in a gridded structure to allow quick access
%  
% Syntax
%   S3G = regularSO3Grid(CS)
%   S3G = regularSO3Grid(CS,SS,'resolution',2.5*degree)     % specify the resolution
%   S3G = regularSO3Grid(CS,SS,'resolution',5*degree,'ZYZ') % use ZYZ convention
%   S3G = regularSO3Grid(CS,SS,'phi2','sections',10) % 10 phi2 sections
%   S3G = regularSO3Grid
%   S3G = equispacedSO3Grid(CS,SS,'points',n)
%   S3G = equispacedSO3Grid(CS,'resolution',res)
%
%   % fill only a ball with radius of 20 degree
%   S3G = equispacedSO3Grid(CS,'maxAngle',20*degree)
%
% Input
%  CS  - @crystalSymmetry
%  SS  - @specimenSymmetry
%   n  - approximate number of points
%  res - resolution in radiant
%
% Output
%  S3G - @SO3Grid
%
% Options
%  maxAngle - radius of the ball to be filles
%  center - center of the ball
%  sections - number of sections
%
% Flags
%  phi1 | Phi | phi2 - sections along which variable
%
  
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
