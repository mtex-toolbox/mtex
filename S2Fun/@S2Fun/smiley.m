function f = smiley(varargin)

if nargin == 0 || ~isa(varargin{1},'vector3d')
  if check_option(varargin,'exact')
    f = S2FunHandle(@(v) S2Fun.smiley(v));
  else
    f = S2FunHarmonic.quadrature(@(v) S2Fun.smiley(v),varargin{:});
  end
  return;
end

v = varargin{1};
v = v(:)';

% Radial test function: quadratic spline
f_r = @(z,h) (z>h).*(z-h).^2./(1-h).^2;
if check_option(varargin,'even')
  f_r = @(z,h) f_r(z,h)+f_r(-z,h); % f has to be even
end

x_0 = [pi/2,0; 0.6,-0.6; 0.6,0.6; -0.5,-1; -0.5,-0.5;...
  -0.5,0; -0.5,0.5; -0.5,1; 0, 0];
h_0 = [0.7; 0.96; 0.96; 0.93; 0.93; 0.93; 0.93; 0.93; 0.96];
c_0 = [0.5; -0.5; -0.5; -0.25; -0.25; -0.25; -0.25; -0.25; 0.4];

centers = vector3d.byPolar(x_0(:, 1), x_0(:, 2));
if strcmpi(getMTEXpref('xAxisDirection'),'east')
  centers = rotate(centers,90*degree);
end

% TODO: upper line can be replaced by lower line with Matlab 2017
fh = @(v) (sum(repmat(c_0,1,length(v)) .* f_r(dot(repmat(v,length(centers),1), repmat(centers,1,length(v))), repmat(h_0,1,length(v))), 1))';
%fh = @(v) (sum(c_0.*f_r(dot(v, centers), h_0), 1))';

f = fh(v);

end
