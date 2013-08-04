function ebsd = horzcat(varargin)
% overloads [ebsd1,ebsd2,ebsd3..]
%
% Syntax 
% [ebsd(1) ebsd(2)]
% 


if nargin == 1, 
  ebsd = varargin{1};
  return;
end

varargin(cellfun('isempty',varargin)) = [];

ebsd = varargin{1};

for k=1:numel(varargin)
  s(k) = struct(varargin{k});
end

ebsd.phaseMap = vertcat(s.phaseMap);
ebsd.CS = horzcat(s.CS);
ebsd.rotations = vertcat(s.rotations);
ebsd.phase = vertcat(s.phase);

prop = [s.prop];

for fn = fieldnames(prop)'
  if length(s(1).prop.(char(fn))) == length(s(1).rotations)
    ebsd.prop.(char(fn)) = vertcat(prop.(char(fn)));  
  end
end

[ebsd.phaseMap,b] = unique(ebsd.phaseMap);
ebsd.CS = ebsd.CS(b);
