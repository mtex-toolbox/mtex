%% Spin Tensors
%
%
%% Spin Tensors as Ininitesimal Changes of Rotations
%
% Spin tensors are skew symmetric tensors that can be used to approximate
% small rotational changes. Lets consider an arbitrary reference rotation

rot_ref = rotation.byEuler(10*degree,20*degree,30*degree)

%%
% and pertube it by a rotating about the axis (123) and angle delta. Since
% multiplication of rotations is not commutativ we have to distinguish
% between left and right pertubations

delta = 0.01*degree;
rot_right = rotation.byAxisAngle(vector3d(1,2,3),delta) * rot_ref;
rot_left = rot_ref * rotation.byAxisAngle(vector3d(1,2,3),delta);

%%
% We may now ask for the first order Taylor coefficients of the pertubation
% as delta goes to zero which we find by the formula
%
% $$ T = \lim_{\delta \to 0} \frac{\tilde R - R}{\delta}
%

T_right = (rot_right.matrix - rot_ref.matrix)./delta
T_left = (rot_left.matrix - rot_ref.matrix)./delta

%%
% Both matrices |T_right| and |T_left| are elements of the tangential space
% attached to the reference rotation rot_ref. Those matrices are
% characterized by the fact that they becomes scew symmetric matrices when
% multiplied from the left or from the right with the inverse of the
% reference rotation

S_right_L =  matrix(inv(rot_ref)) * T_right
S_right_R = T_right * matrix(inv(rot_ref))

S_left_L =  matrix(inv(rot_ref)) * T_left
S_left_R = T_left * matrix(inv(rot_ref))


%%
% A scew symmetric 3x3 matrix |S| is essentially determined by its entries
% $S_{21}$, $S_{31}$ and $S_32$. Writing these values as a vector
% $(S_32,-S_{31},S_{21})$ we obtain for the matrices |S_right_R| and
% |S_left_L| exactly the rotational axis of our pertubation

vector3d(spinTensor(S_right_R)) * sqrt(14)

vector3d(spinTensor(S_left_L))  *sqrt(14)


%%
% For the other two matrices those vectors are related to the rotatinal
% axis by the reference rotation |rot_ref|

rot_ref * vector3d(spinTensor(S_right_L)) * sqrt(14)

inv(rot_ref) * vector3d(spinTensor(S_left_R)) * sqrt(14)

%% The Functions Log
%
% The above definition of the spin tensor works only well if the
% pertupation rotation has small rotational angle. For large pertubations
% the matrix logarithm is the accurate way to compute the skew symmetric
% matrix, i.e., the spinTensor, of the rotational change between an
% reference orientation and another orientation.

rot_123 = rotation.byAxisAngle(vector3d(1,2,3),57.3*degree)
S = logm(rot_ref * rot_123,rot_ref)

S = logm(rot_123 * rot_ref,rot_ref,'left')

%%
% Again we may extract the rotational axis directly from the spin tensor

% the rotational axis
vector3d(S) * sqrt(14)

% the rotational angle in degree
norm(vector3d(S)) / degree

%% 
% Alternatively, we may compute the misorientation vector directly by

v = log(rot_ref * rot_123,rot_ref); v * sqrt(14)

log(rot_123 * rot_ref,rot_ref,'left') * sqrt(14)

%% The Exponential Function Exp
%
% The exponential function is the inverse of function of the logarithm and
% hence it takes a spinTensor or a misorientation vector it turns it into a
% misorientation.

% applying a misorientation directly to the reference orientation
rot_ref * rot_123

% do the same with spinTensor
exp(S,rot_ref)

% do the same with the misorientation vector
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
ori_ref = orientation.byEuler(10*degree,20*degree,30*degree,cs)

% next we disturb rot_ref by a rotation about the axis (123)
mori_123 = orientation.byAxisAngle(Miller(1,2,-3,3,cs),1)

% first we multiply from the right
ori = ori_ref * mori_123;

%%

S_right_L =  matrix(inv(rot_ref)) * T_right
S_right_R = T_right * matrix(inv(rot_ref))

S_left_L =  matrix(inv(rot_ref)) * T_left
S_left_R = T_left * matrix(inv(rot_ref))


%% make it a vector

vR1 = vector3d(spinTensor(S_right_L))  *sqrt(14)
vR2 = inv(rot_ref) * vector3d(spinTensor(S_right_R)) * sqrt(14)

lR1 = rot_ref * vector3d(spinTensor(S_left_L))  *sqrt(14)
lR2 = vector3d(spinTensor(S_left_R)) * sqrt(14)


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



