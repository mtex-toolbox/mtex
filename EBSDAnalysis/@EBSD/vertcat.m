function ebsd = vertcat(varargin)
% overloads [ebsd1;ebsd2;ebsd3..]
% Syntax
% [ebsd(1); ebsd(2)] - 
% [ebsd('fe'); ebsd('mg')] - 

ebsd = horzcat(varargin{:});

