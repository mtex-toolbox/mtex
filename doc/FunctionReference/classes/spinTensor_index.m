%% Spin Tensors
%
%
% 


% consider an arbitrary rotation
rot_ref = rotation('Euler',10*degree,20*degree,30*degree)

% next we disturb rot_ref by a rotation about the axis (123)
rot_123 = rotation('axis',vector3d(1,2,3),'angle',1)

delta = 10*degree
angle(rot_123.^delta)./degree

% first we multiply from the right
rot = rot_ref * rot_123;

%%
% We can approximate elements of the tangential space at rotation rot_ref
% by 
% 
% $$ S = \lim_{\delta \to 0} \frac{\tilde R - R}{\delta}
% 
%disturbing rot_ref by a small rotation

% rotation about the axis (123)
rot_123 = rotation('axis',vector3d(1,2,3),'angle',1)

%%
% and devide about the amount of this pertubation

delta = 0.01*degree
T_right = (matrix(rot_ref * rot_123.^delta) - rot_ref.matrix)./delta
T_left = (matrix(rot_123.^delta * rot_ref) - rot_ref.matrix)./delta

%%

SR1 =  matrix(inv(rot_ref)) * T_right
SR2 = T_right * matrix(inv(rot_ref))

SL1 =  matrix(inv(rot_ref)) * T_left
SL2 = T_left * matrix(inv(rot_ref))


%% make it a vector

vR1 = vector3d(spinTensor(SR1))  *sqrt(14)
vR2 = inv(rot_ref) * vector3d(spinTensor(SR2)) * sqrt(14)

lR1 = rot_ref * vector3d(spinTensor(SL1))  *sqrt(14)
lR2 = vector3d(spinTensor(SL2)) * sqrt(14)


%% logarithm to vector3d

log(rot_ref * rot_123,rot_ref) * sqrt(14)

log(rot_123 * rot_ref,rot_ref,'left') * sqrt(14)

%% logarithm to skew symmetric matrix

S = logm(rot_ref * rot_123,rot_ref)
vector3d(S) * sqrt(14)

S = logm(rot_123 * rot_ref,rot_ref,'left')
vector3d(S) * sqrt(14)


%% The other way round

S = logm(rot_ref * rot_123,rot_ref);
rot_ref * rot_123
exp(S,rot_ref)

v = log(rot_ref * rot_123,rot_ref);
exp(v,rot_ref)

%%

S = logm(rot_123 * rot_ref,rot_ref,'left');
rot_123 * rot_ref
exp(S,rot_ref,'left')

v = log(rot_123 * rot_ref,rot_ref,'left');
exp(v,rot_ref,'left')


%% Now the same with orientations

cs = crystalSymmetry('321')

% consider an arbitrary rotation
ori_ref = orientation('Euler',10*degree,20*degree,30*degree,cs)

% next we disturb rot_ref by a rotation about the axis (123)
mori_123 = orientation('axis',Miller(1,2,-3,3,cs),'angle',1)

% first we multiply from the right
ori = ori_ref * mori_123;

%%

SR1 =  matrix(inv(rot_ref)) * T_right
SR2 = T_right * matrix(inv(rot_ref))

SL1 =  matrix(inv(rot_ref)) * T_left
SL2 = T_left * matrix(inv(rot_ref))


%% make it a vector

vR1 = vector3d(spinTensor(SR1))  *sqrt(14)
vR2 = inv(rot_ref) * vector3d(spinTensor(SR2)) * sqrt(14)

lR1 = rot_ref * vector3d(spinTensor(SL1))  *sqrt(14)
lR2 = vector3d(spinTensor(SL2)) * sqrt(14)


%% logarithm to vector3d

log(ori_ref * mori_123,ori_ref)

log(rot_123 * ori_ref,ori_ref,'left') * sqrt(14)

%% logarithm to skew symmetric matrix

S = logm(ori_ref * mori_123,ori_ref)
round(vector3d(S))

S = logm(rot_123 * ori_ref,ori_ref,'left')
vector3d(S) * sqrt(14)


%% The other way round

S = logm(ori_ref * mori_123,ori_ref);
ori_ref * mori_123
exp(S,ori_ref)

v = log(ori_ref * mori_123,ori_ref);
exp(v,ori_ref)

%%

S = logm(rot_123 * ori_ref,ori_ref,'left');
rot_123 * ori_ref
exp(S,ori_ref,'left')

v = log(rot_123 * ori_ref,ori_ref,'left');
exp(v,ori_ref,'left')

%%




v = vector3d.rand(100);
v.x = 0;
v = rotation.rand * v + vector3d.rand;

vsave = v;

%%

s = v(1);

% shift to origin
v = v - s;

% compute normal vector
[n,~] = eig3(v*v);


r = rotation.map(n(1),zvector);

v = r * v;

plot3(v.x,v.y,v.z,'.')

%%

P = [v.x(:),v.y(:)];
T = delaunayn(P);
n = size(T,1);
W = zeros(n,1);
C=0;
for m = 1:n
    sp = P(T(m,:),:);
    [null,W(m)]=convhulln(sp);
    C = C + W(m) * mean(sp);
end

C = vector3d(C(1),C(2),0)./sum(W);



%%

hold on
plot3(C.x,C.y,C.z,'MarkerSize',10)
hold off




function test
  % some testing code
  
  cs = crystalSymmetry('321');
  ori1 = orientation.rand(cs);
  ori2 = orientation.rand(cs);

  v = log(ori2,ori1);
  
  % this should be the same
  [norm(v),angle(ori1,ori2)] ./ degree
  
  % and this too
  [ori1 * orientation('axis',v,'angle',norm(v)) ,project2FundamentalRegion(ori2,ori1)]
  
  % in specimen coordinates
  r = log(ori2,ori1,'left');
    
  % now we have to multiply from the left
  [rotation('axis',r,'angle',norm(v)) * ori1 ,project2FundamentalRegion(ori2,ori1)]
  
  % the following output should be constant
  % gO = log(ori1,ori2.symmetrise) % but not true for this
  % gO = log(ori1.symmetrise,ori2) % true for this
  %
  % gO = ori2.symmetrise .* log(ori1,ori2.symmetrise) % true for this
  % gO = ori2 .* log(ori1.symmetrise,ori2) % true for this
  
end





