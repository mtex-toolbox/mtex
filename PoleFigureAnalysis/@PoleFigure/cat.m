function pf = cat(dim,varargin)
% implement cat for PoleFigure
%
% Syntax 
%   pf = cat(dim,pf1,pf2,pf3)
%
% Input
%  dim - dimension
%  pf1, pf2, pf3 - @PoleFigure
%
% Output
%  pf - @PoleFigure
%
% See also
% PoleFigure/horzcat, PoleFigure/vertcat

% concatenate properties
pf = cat@dynProp(dim,varargin{:});

varargin(cellfun(@isempty,varargin)) = []; 
if isempty(varargin), return; end

warning('off','MATLAB:structOnObject');
for k=1:numel(varargin)
  s(k) = struct(varargin{k}); %#ok<AGROW>
end
warning('on','MATLAB:structOnObject');

pf.allH = cat(dim,s.allH);
pf.allR = cat(dim,s.allR);
pf.allI = cat(dim,s.allI);
pf.c = cat(dim,s.c);
