%% Spin Tensors as Infinitesimal Changes of Rotations
%
%%
% Spin tensors are skew symmetric tensors that can be used to describe
% small rotational changes. Let us consider an arbitrary reference rotation

rot_ref = rotation.byEuler(10*degree,20*degree,30*degree);

%%
% and perturb it by a rotation about the axis (123) and angle delta=0.01
% degree. Since multiplication of rotations is not commutative we have to
% distinguish between left and right perturbations

delta = 0.01*degree;
rot_123 = rotation.byAxisAngle(vector3d(1,2,3),delta);
rot_right = rot_123 * rot_ref;
rot_left = rot_ref * rot_123;

%%
% We may now ask for the first order Taylor coefficients of the
% perturbation as delta goes to zero which we find by the formula
%
% $$ T = \lim_{\delta \to 0} \frac{\tilde R - R}{\delta} $$
%

T_right = (rot_right.matrix - rot_ref.matrix) ./ delta
T_left = (rot_left.matrix - rot_ref.matrix) ./ delta

%%
% Both matrices |T_right| and |T_left| are elements of the tangential space
% attached to the reference rotation rot_ref. Those matrices are
% characterized by the fact that they becomes skew symmetric matrices when
% multiplied from the left or from the right with the inverse of the
% reference rotation

S_right_L =  matrix(inv(rot_ref)) * T_right
S_right_R = T_right * matrix(inv(rot_ref))

S_left_L =  matrix(inv(rot_ref)) * T_left
S_left_R = T_left * matrix(inv(rot_ref))


%%
% A skew symmetric 3x3 matrix |S| is essentially determined by its entries
% $S_{21}$, $S_{31}$ and $S_{32}$. Writing these values as a vector
% $(S_32,-S_{31},S_{21})$ we obtain for the matrices |S_right_R| and
% |S_left_L| exactly the rotational axis of our perturbation

vector3d(spinTensor(S_right_R)) * sqrt(14)

vector3d(spinTensor(S_left_L))  * sqrt(14)


%%
% For the other two matrices those vectors are related to the rotational
% axis by the reference rotation |rot_ref|

rot_ref * vector3d(spinTensor(S_right_L)) * sqrt(14)

inv(rot_ref) * vector3d(spinTensor(S_left_R)) * sqrt(14)

%% The Functions Exp and Log
%
% The above definition of the spin tensor works well only if the
% perturbation has small rotational angle. For large perturbations the
% matrix logarithm <quaternion.log.html |log|> provides the correct way
% to translate rotational changes into skew symmetric matrices

% define a large pertubation with rotational angle 1 radiant
delta = 1; 
rot_123 = rotation.byAxisAngle(vector3d(1,2,3),1);

S = log(rot_ref * rot_123,rot_ref, SO3TangentSpace.rightSpinTensor); S  * sqrt(14)


S = log(rot_123 * rot_ref,rot_ref, SO3TangentSpace.leftSpinTensor); S  * sqrt(14)


%%
% Again the entries $S_{21}$, $S_{31}$ and $S_{32}$ exactly coincide with
% the rotational axis multiplied with the rotational angle.
%
% More directly this disorientation vector may be computed from two
% rotations using the options |SO3TangentSpace.rightVector| and
% |SO3TangentSpace.leftVector|

v = log(rot_ref * rot_123,rot_ref,SO3TangentSpace.rightVector); v * sqrt(14)

v = log(rot_123 * rot_ref,rot_ref,SO3TangentSpace.leftVector); v * sqrt(14)


%% The other way round
% Given a skew symmetric matrix |S| or a disorientation vector |v| we may
% use the command <vector3d.exp.html |exp|> to apply this rotational
% perturbation to a reference rotation |rot_ref|

% the truth
rot_ref * rot_123

% using a disorientation vector
exp(v,rot_ref,SO3TangentSpace.rightVector)

% using a spin tensor
exp(S,rot_ref,SO3TangentSpace.rightSpinTensor)

%%

% the other truth
rot_123 * rot_ref

% using a disorientation vector
exp(v,rot_ref,SO3TangentSpace.leftVector)

% using a spin tensor
exp(S,rot_ref,SO3TangentSpace.leftSpinTensor)

%% Disorientations under the presence of crystal symmetry
% Under the presence of crystal symmetry the order whether a rotational
% perturbation is applied from the left or from the right. Lets perform the
% above calculations step by step in the presence of trigonal crystal
% symmetry

cs = crystalSymmetry('321');

% consider an arbitrary rotation
ori_ref = orientation.byEuler(10*degree,20*degree,30*degree,cs);

% next we disturb rot_ref by a rotation about the axis (123)
mori_123 = orientation.byAxisAngle(Miller(1,2,-3,3,cs),1);

% first we multiply from the right
ori = ori_ref * mori_123

%%
% Computing the right tangential vector gives us the disorientation vector
% in crystal coordinates

v = log(ori,ori_ref,SO3TangentSpace.rightVector); round(v)

exp(v,ori_ref,SO3TangentSpace.rightVector)

%%
% computing the left tangential vector gives us the disorientation vector
% in specimen coordinates

v = log(ori,ori_ref,SO3TangentSpace.leftVector)
S = log(ori,ori_ref,SO3TangentSpace.leftSpinTensor)
exp(v,ori_ref,SO3TangentSpace.leftVector)
