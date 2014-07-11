function q = vertcat(varargin)
% implements [q1;q2;q3..]

q = cat(1,varargin{:});
