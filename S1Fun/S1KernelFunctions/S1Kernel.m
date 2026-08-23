classdef S1Kernel < S1FunHarmonic
% an abstract class representing kernel functions on the circle
%  
% A kernel on the circle is a nonnegative even function concentrated at 0,
% stored as an @S1FunHarmonic. Deriving classes give its Fourier
% coefficients a closed form; the halfwidth and the arithmetics come from
% here.
%
% Syntax
%   psi = S1Kernel(fhat)
%
% Input
%  fhat - Fourier coefficients, from degree -N to N
%
% Output
%  psi - @S1Kernel
%
% Class Properties
%  fhat      - Fourier coefficients
%  bandwidth - maximum harmonic degree
%
% Derived Classes
%  @S1DeLaValleePoussinKernel - de la Vallee Poussin kernel
%  @S1DirichletKernel         - Dirichlet kernel
%  @S1FejerKernel             - Fejer kernel
%  @S1BumpKernel              - indicator function of an interval
%
% See also
% S1DirichletKernel S1FejerKernel S1DeLaValleePoussinKernel S1BumpKernel
%

  methods
    
    function S1K = S1Kernel(fhat, varargin)
      if nargin == 0, return; end
      
      if isa(fhat,'S1Kernel')
        S1K.fhat = fhat.fhat;
      else
        S1K.fhat = fhat;
      end
      
    end
     
    % standard output
    function display(psi)
      displayClass(psi,inputname(1));      
      disp(['  bandwidth: ',int2str(psi.bandwidth)]);
      disp(['  halfwidth: ',xnum2str(psi.halfwidth/degree) mtexdegchar]);      
      disp(' ');
    end

    function c = char(psi)
      c = ['custom, halfwidth ' xnum2str(psi.halfwidth/degree) mtexdegchar];
    end

    function hw = halfwidth(psi)
      % Find halfwidth by function evaluations

      if psi.fhat==0
        hw = 0;
        return
      end

      if psi.bandwidth<1000
        epsilon = 0.01;
      else
        epsilon = 0.1;
      end

      % evaluate psi
      v = abs(psi.eval((0:epsilon:180)*degree));
      % get maximum value
      [my,mind] = max(v);
      %       shift
      %       v = [flip(v(2:end));v];
      %       mx = (mind-1)*epsilon;
      % shift halfwide to roots
      v = my-2*v;

      hr = find(v(mind:end)>=0,1,'first')-1;
      if isempty(hr), hr=0; end
      hl = mind-find(v(1:mind)>=0,1,'last');
      if isempty(hl), hl=0; end
      hw = max(hl,hr)*epsilon*degree;
 
    end

  end

   methods (Access=protected)
           
    function fhat = cutA(psi)
      % cut of Fourier coefficients when they are sufficently small

      epsilon = getMTEXpref('FFTAccuracy',1E-2) / 150;
      fhat = psi.fhat(:);
      bw = psi.bandwidth;

      A = sqrt(abs(fhat(bw+2:end)).^2 + abs(fhat(bw:-1:1)).^2);
      ind = find(A<=max(min([A;10*epsilon]),epsilon),1,'first')-1;
      if ~isempty(A)
        psi.bandwidth = ind-1;
        fhat = fhat(bw+1-ind:bw+1+ind);
      end
    end

   end
end