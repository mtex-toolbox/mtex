function ebsd = cat(dim,varargin)
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
ebsd = cat@dynProp(1,varargin{:});

for k=1:numel(varargin)
  s(k) = struct(varargin{k});
end

ebsd.phaseMap = vertcat(s.phaseMap);
ebsd.CSList = horzcat(s.CSList);
ebsd.rotations = cat(1,s.rotations);

[ebsd.phaseMap,b] = unique(ebsd.phaseMap);
ebsd.CSList = ebsd.CSList(b);
