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

if isa(g,'orientation') && (odf.CS.Laue ~= g.CS.Laue || ...
    odf.SS.Laue ~= g.SS.Laue)
  warning('symmetry missmatch'); %#ok<WNTAG>
end

% evaluate components
f = zeros(size(g));

if isempty(f), return; end

for i = 1:numel(odf.components)
  f = f + odf.weights(i) * reshape(...
    eval(odf.components{i},g,varargin{:}),size(g));
end
