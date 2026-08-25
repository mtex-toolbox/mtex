%% Spin Tensors as Infinitesimal Changes of Rotations
%
%%
% A spin tensor is a skew symmetric matrix, and it is how a *rate* of
% rotation is written: not where a body has turned to, but how fast and
% about which axis it is turning right now. This is the form in which
% rotation enters continuum mechanics - the antisymmetric part of a velocity
% gradient is a spin tensor - and it is the matrix side of the
% <RotationTangentSpace.html tangent space>.
%
% Start from a reference rotation.

rot_ref = rotation.byEuler(10*degree,20*degree,30*degree);

%%
% Perturb it by a small rotation about the axis $(123)$, by
% $\delta = 0.01^\circ$. Rotations do not commute, so it matters whether
% the perturbation is applied before or after the reference rotation.

delta = 0.01*degree;
rot_123 = rotation.byAxisAngle(vector3d(1,2,3),delta);
rot_right = rot_123 * rot_ref;
rot_left = rot_ref * rot_123;

%%
% The first order Taylor coefficient of the perturbation, as $\delta$ goes
% to zero, is
%
% $$ T = \lim_{\delta \to 0} \frac{\tilde R - R}{\delta} $$
%

T_right = (rot_right.matrix - rot_ref.matrix) ./ delta
T_left = (rot_left.matrix - rot_ref.matrix) ./ delta

%%
% What such a derivative means is easier to see than to read. Turning a
% direction steadily about an axis sends it round a circle; the spin tensor
% is the velocity it sets off with. Below, the red arrow is the axis, the
% grey arrow a direction, the black circle the path it travels, and the blue
% arrow the velocity at the instant shown.

om = normalize(vector3d(1,2,3));
v0 = normalize(vector3d(1,0,0));
t = linspace(0,2*pi,300);
tr = rotation.byAxisAngle(om,t) * v0;

plot3(tr.x,tr.y,tr.z,'k','linewidth',1.5)
hold on
arrow3d(1.5*om,'faceColor','red')
arrow3d(v0,'faceColor',[.45 .45 .45])
arrow3d(v0 + 0.6*normalize(cross(om,v0)),'faceColor','blue')
hold off
axis equal off

%%
% |T_right| and |T_left| live in the tangent space at |rot_ref|. Neither is
% skew symmetric by itself - what makes them tangent vectors is that they
% become skew symmetric once the reference rotation is divided out, from the
% left or from the right.

S_right_L =  matrix(inv(rot_ref)) * T_right
S_right_R = T_right * matrix(inv(rot_ref))

S_left_L =  matrix(inv(rot_ref)) * T_left
S_left_R = T_left * matrix(inv(rot_ref))


%%
% Two of the four are skew symmetric, |S_right_R| and |S_left_L|.
%
% A skew symmetric $3 \times 3$ matrix has only three independent entries,
% $S_{21}$, $S_{31}$ and $S_{32}$, and read as the vector
% $(S_{32},-S_{31},S_{21})$ they are the axis of the perturbation, scaled by
% its angle. Undoing the normalisation of the axis returns $(1,2,3)$.

vector3d(spinTensor(S_right_R)) * sqrt(14)

vector3d(spinTensor(S_left_L))  * sqrt(14)


%%
% The other two give the same axis seen in the other frame, i.e. turned by
% the reference rotation.

rot_ref * vector3d(spinTensor(S_right_L)) * sqrt(14)

inv(rot_ref) * vector3d(spinTensor(S_left_R)) * sqrt(14)

%% The Functions Exp and Log
%
% Taking the difference of two rotation matrices is only meaningful while
% the perturbation is small. For a large one the matrix logarithm
% <quaternion.log.html |log|> is the correct translation of a rotational
% change into a skew symmetric matrix - it is exact at any angle.

% define a large perturbation with rotational angle 1 radiant
delta = 1; 
rot_123 = rotation.byAxisAngle(vector3d(1,2,3),1);

S = log(rot_ref * rot_123,rot_ref, SO3TangentSpace.rightSpinTensor); S  * sqrt(14)


S = log(rot_123 * rot_ref,rot_ref, SO3TangentSpace.leftSpinTensor); S  * sqrt(14)


%%
% The three entries again give the axis times the angle, now for a
% perturbation of one radian rather than $0.01^\circ$.
%
% The same is obtained as a vector directly, with
% |SO3TangentSpace.rightVector| and |SO3TangentSpace.leftVector|.

v = log(rot_ref * rot_123,rot_ref,SO3TangentSpace.rightVector); v * sqrt(14)

v = log(rot_123 * rot_ref,rot_ref,SO3TangentSpace.leftVector); v * sqrt(14)


%% The Other Way Round
%
% <vector3d.exp.html |exp|> goes back: given a spin tensor |S| or a rotation
% vector |v|, it applies that perturbation to the reference rotation. The
% first line of each block below is the rotation the perturbation came from,
% so all three results in a block have to agree.

% the truth
rot_ref * rot_123

% using a rotation vector
exp(vector3d(v),rot_ref,SO3TangentSpace.rightVector)

% using a spin tensor
exp(S,rot_ref,SO3TangentSpace.rightSpinTensor)

%%

% the other truth
rot_123 * rot_ref

% using a rotation vector
exp(vector3d(v),rot_ref,SO3TangentSpace.leftVector)

% using a spin tensor
exp(S,rot_ref,SO3TangentSpace.leftSpinTensor)

%% Under Crystal Symmetry
%
% For orientations the side on which a perturbation is applied is not a
% formality: multiplying from the right acts in crystal coordinates,
% multiplying from the left in specimen coordinates, see
% <DefinitionAsCoordinateTransform.html Theory>. The same calculation once
% more, now with trigonal crystal symmetry.

cs = crystalSymmetry('321');

% consider an arbitrary rotation
ori_ref = orientation.byEuler(10*degree,20*degree,30*degree,cs);

% next we disturb rot_ref by a rotation about the axis (123)
mori_123 = orientation.byAxisAngle(Miller(1,2,-3,3,cs),1);

% first we multiply from the right
ori = ori_ref * mori_123

%%
% The right tangent vector is the perturbation written in crystal
% coordinates, so it comes back as a <Miller.Miller.html |@Miller|> - and it
% is the axis $(1,2,\bar3,3)$ the perturbation was defined with.

v = Miller(log(ori,ori_ref,SO3TangentSpace.rightVector),ori.CS); round(v)

exp(v,ori_ref,SO3TangentSpace.rightVector)

%%
% The left tangent vector is the same perturbation in specimen coordinates -
% different numbers, same rotation, and |exp| returns the orientation either
% way.

v = log(ori,ori_ref,SO3TangentSpace.leftVector)

%%

S = log(ori,ori_ref,SO3TangentSpace.leftSpinTensor)

%%

exp(v,ori_ref,SO3TangentSpace.leftVector)

%% Next
%
% The objects that carry a tangent vector together with its base point and
% its representation are <RotationTangentSpace.html SO3TangentVector>. Spin
% tensors are the antisymmetric part of a velocity gradient, which is where
% they meet the material description in <TensorDefinition.html Tensors>.

%#ok<*NOPTS>
