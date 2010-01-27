function s = horzcat(varargin)
% overloads [v1,v2,v3..]

% TODO! sort theta

s = varargin{1};

for i = 2:numel(varargin)
  
  s2 = varargin{i};
  if isa(s2,'S2Grid')
    s.res = min(s.res,s2.res);
    s.theta = [s.theta,s2.theta];
    s.rho = [s.rho,s2.rho];
    s.vector3d = [reshape(s.vector3d,1,[]),reshape(s2.vector3d,1,[])];
    s.options = {s.options{:},s2.options{:}};
  end
end
