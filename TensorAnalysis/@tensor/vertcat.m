function T = vertcat(varargin)
% overloads [T1,T2,T3..]

T = cat(1,varargin{:});