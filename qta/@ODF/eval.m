function f = eval(odf,g,varargin)
% evaluate an odf at orientation g
%
%
% Input
%  odf - @ODF
%  g   - @orientation
%
% Flags
%  even       - calculate even portion only
%
% Output
%  f   - values of the ODF at the orientations g
%
% See also
% kernel/sum_K kernel/K

if isa(g,'orientation') && odf(1).CS ~= g.CS && odf(1).SS ~= g.SS
  warning('symmetry missmatch'); %#ok<WNTAG>
end
f = zeros(size(g));

for i = 1:numel(odf)   
  f = f + odf(i).weight * reshape(doEval(odf(i),g,varargin{:}),size(g));
end
