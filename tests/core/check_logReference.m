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

checkSymmetryCarriage;

disp('check_logReference: ok')

end

% ------------------------------------------------------------------------

function checkSymmetryCarriage
% the symmetry pair of the reference survives log and exp
%
% Regression test: quaternion/log builds the tangent vector on a bare
% reference, then orientation/log rewraps it with the real one. The
% SO3TangentVector constructor appended the source's own pair to the
% argument list, and extractSym returns the FIRST symmetry it finds - so
% the trivial pair of the bare inner reference outranked the caller's
% orientation. It stayed invisible while a fabricated default was
% indistinguishable from an absent symmetry; once absence became empty
% (ADR 0003) every log and exp silently returned triclinic.

cs = crystalSymmetry('321');
ss = specimenSymmetry('222');
ori_ref = orientation.byEuler(10*degree,20*degree,30*degree,cs,ss);
ori = ori_ref * orientation.byAxisAngle(Miller(1,2,-3,3,cs),1,cs,cs);

for tS = [SO3TangentSpace.rightVector,SO3TangentSpace.leftVector]

  v = log(ori,ori_ref,tS);
  ref = v.oriRef;

  if ref.CS.id ~= cs.id || ref.SS.id ~= ss.id
    error('log dropped a symmetry of the reference, tangentSpace %d',double(tS));
  end

  % the frames ride along with the groups - a refabricated symmetry would
  % carry the session frame instead of the one of the data
  if ref.CS.frame ~= cs.frame || ref.SS.frame ~= ss.frame
    error('log dropped a reference frame, tangentSpace %d',double(tS));
  end

  e = exp(v,ori_ref,tS);
  if e.CS.id ~= cs.id || e.SS.id ~= ss.id
    error('exp(log(ori,ori_ref)) dropped a symmetry, tangentSpace %d',double(tS));
  end
end

% the reference is the single source of the pair, so a tangent vector has to
% survive being rebuilt from its own oriRef. Not from its rot - that one
% shows the equivariant side as a trivial stand-in on purpose
v = log(ori,ori_ref,SO3TangentSpace.leftVector);
r = SO3TangentVector(v,v.oriRef,v.tangentSpace);
ref = r.oriRef;
if ref.CS.id ~= cs.id || ref.SS.id ~= ss.id
  error('rebuilding a tangent vector from its own reference dropped a symmetry');
end

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
