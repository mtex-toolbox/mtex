function ebsd = horzcat(varargin)
% overloads [ebsd1,ebsd2,ebsd3..]
%
% Syntax 
% [ebsd(1) ebsd(2)]
% 

% maybe there is nothing to do
varargin(cellfun('isempty',varargin)) = [];
if nargin == 1, 
  ebsd = varargin{1};
  return;
end

% concatenate properties
ebsd = horzcat@dynProp(varargin{:});

for k=1:numel(varargin)
  s(k) = struct(varargin{k});
end

ebsd.phaseMap = vertcat(s.phaseMap);
ebsd.CS = horzcat(s.allCS);
ebsd.rotations = vertcat(s.rotations);

[ebsd.phaseMap,b] = unique(ebsd.phaseMap);
ebsd.CS = ebsd.allCS(b);
