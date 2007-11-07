function q = vertcat(varargin)
% implements [q1,q2,q3..]

q = quaternion;

for i = 1:length(varargin)
    q.a = [q.a;varargin{i}.a];
    q.b = [q.b;varargin{i}.b];
    q.c = [q.c;varargin{i}.c];
    q.d = [q.d;varargin{i}.d];
end
