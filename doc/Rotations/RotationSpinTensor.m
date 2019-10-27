%% Spin Tensors as Ininitesimal Changes of Rotations
%
%%
% Spin tensors are skew symmetric tensors that can be used to describe
% small rotational changes. Lets consider an arbitrary reference rotation

rot_ref = rotation.byEuler(10*degree,20*degree,30*degree);

%%
% and pertube it by a rotation about the axis (123) and angle delta. Since
% multiplication of rotations is not communatativ we have to distinguish
% between left and right pertubations

delta = 0.01*degree;
rot_123 = rotation.byAxisAngle(vector3d(1,2,3),delta);
rot_right = rot_123 * rot_ref;
rot_left = rot_ref * rot_123;

%%
% We may now ask for the first order Taylor coefficients of the pertubation
% as delta goes to zero which we find by the formula
%
% $$ T = \lim_{\delta \to 0} \frac{\tilde R - R}{\delta} $$
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
% $S_{21}$, $S_{31}$ and $S_{32}$. Writing these values as a vector
% $(S_32,-S_{31},S_{21})$ we obtain for the matrices |S_right_R| and
% |S_left_L| exactly the rotational axis of our pertubation

vector3d(spinTensor(S_right_R)) * sqrt(14)

vector3d(spinTensor(S_left_L))  *sqrt(14)


%%
% For the other two matrices those vectors are related to the rotational
% axis by the reference rotation |rot_ref|

rot_ref * vector3d(spinTensor(S_right_L)) * sqrt(14)

inv(rot_ref) * vector3d(spinTensor(S_left_R)) * sqrt(14)

%% The Functions Exp and Log
%
% The above definition of the spin tensor works only well if the
% pertupation rotation has small rotational angle. For large pertubations
% the <quaternion.logm.html matrix logarithm> provides the correct way to
% translate rotational changes into skew symmetric matrices

S = logm(rot_ref * rot_123,rot_ref)

S = logm(rot_123 * rot_ref,rot_ref,'left')

%%
% Again the entries $S_{21}$, $S_{31}$ and $S_{32}$ exactly coincide with
% the rotional axis multiplied with the rotational angle

vector3d(S) * sqrt(14)

%%
% More directly this disorientation vector may be computed from two
% rotations by the command <quaternion.log.html log>


rot_123 = rotation.byAxisAngle(vector3d(1,2,3),1)
log(rot_ref * rot_123,rot_ref) * sqrt(14)

log(rot_123 * rot_ref,rot_ref,'left') * sqrt(14)


%% The other way round
% Given a skew symmetric matrix *S* or a disorientation vector *v* we may
% use the command <vector3d.exp.html exp> to apply this rotational
% pertubation to a reference rotation *rot_ref*

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


%% Disorientations under the presence of crystal symmetry
% Under the presence of crystal symmetry the order whether a rotational
% pertupation is applied from the left or from the right. Lets perform the
% above calculations step by step in the presence of trigonal crystal
% symmetry

cs = crystalSymmetry('321');

% consider an arbitrary rotation
ori_ref = orientation.byEuler(10*degree,20*degree,30*degree,cs);

% next we disturb rot_ref by a rotation about the axis (123)
mori_123 = orientation.byAxisAngle(Miller(1,2,-3,3,cs),1)

% first we multiply from the right
ori = ori_ref * mori_123

%%
% and compute the scew symmetric pertubation matrices

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

