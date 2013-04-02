function ebsd = horzcat(varargin)
% overloads [ebsd1,ebsd2,ebsd3..]
%
%% Syntax 
% [ebsd(1) ebsd(2)]
% 

varargin(cellfun('isempty',varargin)) = [];

ebsd = varargin{1};

for k=1:numel(varargin)
  s(k) = struct(varargin{k});
end

ebsd.phaseMap = vertcat(s.phaseMap);
ebsd.CS = horzcat(s.CS);
ebsd.rotations = vertcat(s.rotations);
ebsd.phase = vertcat(s.phase);

options = [s.options];

for fn = fieldnames(options)'
  ebsd.options.(char(fn)) = vertcat(options.(char(fn)));
end

[ebsd.phaseMap b] = unique(ebsd.phaseMap);
ebsd.CS = ebsd.CS(b);

