function grains = vertcat(varargin)
% concatenation of grains from the same GrainSet
%
%% Syntax
% g = [grains_1; grains_2; ...; grains_n]
%
%% See also
% GrainSet/hortcat

grains = horzcat(varargin{:});