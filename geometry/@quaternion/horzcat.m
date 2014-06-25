function q = horzcat(varargin)
% implements [q1,q2,q3..]

q = cat(2,varargin{:});
