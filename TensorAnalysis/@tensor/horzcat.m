function T = horzcat(varargin)
% overloads [T1,T2,T3..]

T = cat(2,varargin{:});
