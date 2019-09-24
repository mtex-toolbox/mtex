%% SUB: Calculating Misorientations
%
% Let cs and ss be crystal and specimen symmetry and o1 and o2 two crystal
% orientations. Then one can ask for the misorientation between both
% orientations. This misorientation can be calculated by the function
% <orientation.angle.html angle>.

angle(rot * o1,o1) / degree

%%
% This misorientation angle is, in general, smaller than the misorientation
% without crystal symmetry which can be computed via

angle(rotation(ori),rotation(o1)) /degree

%% SUB: Calculating with Orientations and Rotations
%
% Besides the standard linear algebra operations there are also the
% following functions available in MTEX. Then rotational angle and the axis
% of rotation can be computed via then commands
% <quaternion.angle.html angle(o)> and
% <quaternion.axis.html axis(o)>

angle(o1)/degree

axis(o1)