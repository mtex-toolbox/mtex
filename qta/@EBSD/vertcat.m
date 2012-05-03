function ebsd = vertcat(varargin)
% overloads [ebsd1;ebsd2;ebsd3..]
%% Syntax
% [ebsd(1); ebsd(2)] - 
% [ebsd('fe'); ebsd('mg')] - 

ebsd = horzcat(varargin{:});

% ebsd = varargin{1};
% 
% for i = 2:length(varargin)
% 
%   for fn = fieldnames(ebsd.options)'
%     cfn = char(fn);
%     ebsd.options.(cfn) = vertcat(ebsd.options.(cfn),varargin{i}.options.(cfn));
%   end
%   ebsd.rotations = vertcat(ebsd.rotations,varargin{i}.rotations);
%   ebsd.phase =  vertcat(ebsd.phase,varargin{i}.phase);
% 
% end
