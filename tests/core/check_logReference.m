function check_logReference
% check that log(ori,ori_ref) respects an array valued reference
%
% Regression test: the reference orientation used to be subtracted only
% inside a guard "if ori_ref ~= quaternion.id". For an array valued reference
% such a condition collapses into an all() over all elements and, since ne is
% symmetry aware, a single reference orientation coinciding with a symmetry
% element made log silently return the logarithms taken at the identity - for
% every element.

cs = crystalSymmetry('432');
rng(0)
N = 100;
ori = orientation.rand(N,cs);

ref = orientation.rand(N,cs);
refs = {ref};
refs{2} = ref; refs{2}(17) = orientation.id(cs);         % identity reference
refs{3} = ref; refs{3}(23) = orientation(cs.rot(5),cs);  % symmetry element

for tS = [SO3TangentSpace.rightVector,SO3TangentSpace.leftVector]
  for k = 1:numel(refs)

    % log has to coincide with the spelled out computation
    v = vector3d(log(ori,refs{k},tS));
    if max(norm(v - refLog(ori,refs{k},tS))) > 1e-10
      error('log ignores the reference orientation, tangentSpace %d, case %d',...
        double(tS),k);
    end

    % and exp has to invert it
    if max(angle(exp(log(ori,refs{k},tS),refs{k},tS),ori)) > 1e-4
      error('exp(log(ori,ori_ref)) ~= ori, tangentSpace %d, case %d',...
        double(tS),k);
    end
  end
end

% the same for rotations, i.e. quaternion/log
rot = rotation.rand(N);
rotRef = rotation.rand(N); rotRef(3) = rotation.id;

for tS = [SO3TangentSpace.rightVector,SO3TangentSpace.leftVector]

  v = vector3d(log(rot,rotRef,tS));

  if tS.isRight
    m = itimes(rotRef,rot,true);
  else
    m = itimes(rot,rotRef,false);
  end

  if max(norm(v - vector3d(log(m,tS)))) > 1e-10
    error('quaternion/log ignores the reference, tangentSpace %d',double(tS));
  end
end

% without a reference the logarithm is taken in the fundamental region with
% respect to both symmetries
oriSS = orientation.rand(N,cs,specimenSymmetry('222'));
v = vector3d(log(oriSS));
vRef = vector3d(log(project2FundamentalRegion(oriSS),'noSymmetry'));

if max(norm(v - vRef)) > 1e-10
  error('log without reference orientation is broken');
end

disp('check_logReference: ok')

end

% ------------------------------------------------------------------------

function v = refLog(ori,ref,tS)
% what log(ori,ref,tS) is supposed to do, spelled out

if tS.isRight
  m = orientation(itimes(ref,ori,true),ori.CS,specimenSymmetry);
else
  m = orientation(itimes(ori,ref,false),specimenSymmetry,ori.SS);
end

v = vector3d(log(project2FundamentalRegion(m),'noSymmetry'));

end
