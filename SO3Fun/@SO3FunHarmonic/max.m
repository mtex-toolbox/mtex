function [values,modes] = max(SO3F,varargin)
% global, local and pointwise maxima of functions on SO(3)
%
% Syntax
%   [v,pos] = max(SO3F) % the position where the maximum is atained
%
%   [v,pos] = max(SO3F,'numLocal',5) % the 5 largest local maxima
%
%   SO3F = max(SO3F, c) % maximum of a rotational functions and a constant
%   SO3F = max(SO3F1, SO3F2) % maximum of two rotational functions
%   SO3F = max(SO3F1, SO3F2, 'bandwidth', bw) % specify the new bandwidth
%
%   % compute the maximum of a multivariate function along dim
%   SO3F = max(SO3Fmulti,[],dim)
%
% Input
%  SO3F, SO3F1, SO3F2 - @SO3Fun
%  SO3Fmulti          - a multivariate @SO3Fun
%  c                  - double
%
% Output
%  v - double
%  pos - @rotation / @orientation
%
% Options
%  kmax          - number of iterations
%  numLocal      - number of peaks to return
%  startingNodes - @rotation / @orientation
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximum step size
%
% Flags
%  gradDescent - use gradient Descent (slower)
%  noNFFT      - (together with 'gradDescent') prevent usage of NFFT-methods by direct summation (slow, but computable for very high bandwiths if matlab brokes in other cases)
%
% Example
%
%   %find the local maxima of the <SantaFe.html SantaFe> ODF
%   [value,ori] = max(SantaFe)
%   plotPDF(SantaFe,Miller(0,0,1,ori.CS))
%   annotate(ori)
%
% See also
% SO3Fun/min SO3Fun/max SO3Fun/calcComponents

if isa(SO3F,'SO3FunHarmonic') && ~SO3F.isReal
  SO3F.isReal = 1;
  warning('By taking the maxima of SO3Funs, the functions should be real valued.')
end
if nargin>1 && isa(varargin{1},'SO3FunHarmonic') && ~varargin{1}.isReal
  varargin{1}.isReal = 1;
  warning('By taking the maxima of SO3Funs, the functions should be real valued.')
end

% Do gradient descent
if check_option(varargin,'gradDescent')
  [values,modes] = maxSteepestDescent(SO3F,varargin{:});
  return
end


[values,modes] = max@SO3Fun(SO3F,varargin{:});

end




function [values,modes] = maxSteepestDescent(SO3F,varargin)
  
  % get symmetry
  cs = SO3F.SRight;
  ss = SO3F.SLeft;

  % 1. Evaluate on very large global grid by FFT
  N = get_option(varargin,'bandwidth',128);
  % make bw suitable
  N = quadratureSO3Grid.adjust_bandwidth(N,cs,ss);
  % TODO: adjust kernel to bandwidth
  hw = get_option(varargin,'halfwidth',2*pi/(2*N+2));
  f = smooth(SO3F,SO3DeLaValleePoussinKernel('halfwidth',hw));
  % prevent construction of memory consuming rotation grids.
  rot = struct('scheme','ClenshawCurtis','bandwidth',N,'CS',cs,'SS',ss);
  y = evalEquispacedFFT(f,rot);
  
  % 2. Find maximal values
  width=5;
  msk = true(2*width+1,2*width+1,2*width+1);
  msk(width+1,width+1,width+1) = false;
  y_dil = imdilate(y,msk);
  M = y > y_dil;
  
  % 3. Indicate corresponding rotations
  [u,~,id] = quadratureSO3Grid.uniqueQuadratureSO3Grid(N,'ClenshawCurtis',cs,ss);
  tol = get_option(varargin,'tolerance',5*degree);
  r = unique(u(id(M)),'tolerance',tol);
  
  % 4. Do Steepest Descent with direct Evaluation on that Maxima
  if check_option(varargin,'noNFFT')
    [modes,values] = steepestDescent(SO3F,r,'skipSymmetrise','unique',3*degree,'noNFFT');
  else
    [modes,values] = steepestDescent(SO3F,r,'skipSymmetrise','unique',3*degree);
  end

  % 5. Make output
  len = min(get_option(varargin,'numLocal',1),length(values));
  [values,id] = sort(values,'descend');
  values = values(1:len);
  modes = project2FundamentalRegion(modes(id(1:len)),'Bunge');

end