function check_embedding
% check that embedding/double is an isometry and embedding/setDouble is
% its exact inverse, for every Laue class
%
% See also
% embedding/double embedding/setDouble

tol = 1e-8;

names = {'-1','2/m','mmm','-3','-3m','4/m','4/mmm','6/m','6/mmm','m-3','m-3m'};

for k = 1:numel(names)

  cs = crystalSymmetry(names{k});
  ori = orientation.rand(50,cs);

  e = embedding(ori);
  d = double(e);

  % isometry: Euclidean distance between packed vectors should equal the
  % tensorial distance between the embeddings
  id1 = randi(50,200,1);
  id2 = randi(50,200,1);

  distTensor = norm(e(id1) - e(id2));
  distEuclid = sqrt(sum((d(id1,:) - d(id2,:)).^2,2));

  errIso = max(abs(distTensor - distEuclid));
  if errIso > tol
    error('embedding:isometry','%s: double() is not isometric, error %g',names{k},errIso);
  end

  % setDouble should be the exact inverse of double
  eRec = e; eRec.M = d;
  errInv = max(norm(e - eRec));
  if errInv > tol
    error('embedding:inverse','%s: setDouble() does not invert double(), error %g',names{k},errInv);
  end

  disp([names{k}, ' ..... passed']);

end

disp(' ');
disp('embedding/double and embedding/setDouble passed for all Laue classes');

end
