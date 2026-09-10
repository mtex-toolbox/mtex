classdef (InferiorClasses = {?rotation,?quaternion}) fibonacciSO3Grid < orientation
% low discrepancy grid of orientations from a super Fibonacci spiral
%
% The nodes are the super Fibonacci spiral of
% <https://doi.org/10.1109/CVPR52688.2022.00811 M. Alexa, Super-Fibonacci
% Spirals: Fast, Low-Discrepancy Sampling of SO(3), CVPR 2022>, restricted
% to the fundamental region of the given symmetries. In contrast to a
% lattice the number of nodes is a free parameter. To cover a ball around a
% single orientation use <localOrientationGrid.html localOrientationGrid>.
%
% Syntax
%   S3G = fibonacciSO3Grid(CS)
%   S3G = fibonacciSO3Grid(CS,SS,'points',10000)
%   S3G = fibonacciSO3Grid(CS,SS,'resolution',2.5*degree)
%
% Input
%  CS  - @crystalSymmetry
%  SS  - @specimenSymmetry
%
% Output
%  S3G - @fibonacciSO3Grid
%
% Options
%  points     - approximate number of nodes
%  resolution - node spacing in radiant
%
% See also
% equispacedSO3Grid homochoricSO3Grid fibonacciS2Grid

  properties
    resolution = 2*pi           % node spacing
  end

  methods

    function S3G = fibonacciSO3Grid(varargin)

      if ~isempty(varargin) && isa(varargin{1},'symmetry')
        S3G.CS = varargin{1};
        varargin(1) = [];
      end
      if ~isempty(varargin) && isa(varargin{1},'symmetry')
        S3G.SS = varargin{1};
        varargin(1) = [];
      end

      S3G.antipodal = check_option(varargin,'antipodal');

      % volume fraction of the fundamental region, as in orientation/find
      V = 1/numSym(S3G.CS.properGroup)/numSym(S3G.SS.properGroup)/(1+S3G.antipodal);

      % SO(3) has volume 8*pi^2, hence one node per resolution^3
      if check_option(varargin,'points')
        S3G.resolution = (8*pi^2 * V / get_option(varargin,'points'))^(1/3);
      else
        S3G.resolution = get_option(varargin,'resolution',5*degree);
      end
      N = round(8*pi^2 / S3G.resolution^3);

      % psi is the real root of x^4 = x + 4
      phi = sqrt(2); psi = 1.5337511687552043;

      k = (0:N-1)' + 0.5;
      t = k/N;
      alpha = 2*pi*k/phi;
      beta = 2*pi*k/psi;
      q = quaternion(sqrt(t).*sin(alpha),sqrt(t).*cos(alpha), ...
        sqrt(1-t).*sin(beta),sqrt(1-t).*cos(beta));

      inside = checkInside(fundamentalRegion(S3G.CS,S3G.SS,varargin{:}),q);
      S3G.a = q.a(inside);
      S3G.b = q.b(inside);
      S3G.c = q.c(inside);
      S3G.d = q.d(inside);
      S3G.i = false(size(S3G.a));

    end

  end
end
