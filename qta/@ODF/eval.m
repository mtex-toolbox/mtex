function f = eval(odf,g,varargin)
% evaluate an odf at orientation g
%
%
%% Input
%  odf - @ODF
%  g   - @orientation
%
%% Flags
%  EVEN       - calculate even portion only
%  FOURIER    - use NFSOFT based algorithm
%
%% Output
%  f   - values of the ODF at the orientations g
%
%% See also
% kernel/sum_K kernel/K

if isa(g,'orientation') && odf(1).CS ~= get(g,'CS') && odf(1).SS ~= get(g,'SS')
  warning('symmetry missmatch'); %#ok<WNTAG>
end
f = zeros(size(g));

for i = 1:numel(odf)   
  f = f + odf(i).weight * reshape(doEval(odf(i),g,varargin{:}),size(g));
end
