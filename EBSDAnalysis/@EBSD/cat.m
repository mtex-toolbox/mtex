function ebsd = cat(dim,varargin)
% overloads [ebsd1,ebsd2,ebsd3..]
%
% Syntax 
%   [ebsd(1) ebsd(2)]
% 

% maybe there is nothing to do
varargin(cellfun('isempty',varargin)) = [];
if nargin == 2
  ebsd = varargin{1};
  return;
end

% concatenate properties
ebsd = cat@dynProp(1,varargin{:});

for k = 2:numel(varargin)
  ebsd.phaseId = cat(1,ebsd.phaseId,varargin{k}.phaseId);
  ebsd.id = cat(1,ebsd.id,varargin{k}.id);
  ebsd.rotations = cat(1,ebsd.rotations,varargin{k}.rotations);
end
