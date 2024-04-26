function check_mex

mexFiles = ["jcvoronoi_mex" "EulerCyclesC" "insidepoly_dblengine" ...
  "wignerTrafomex" "wignerTrafoAdjointmex"  "numericalSaddlepointWithDerivatives" ...
  "S1Grid_find" "S1Grid_find_region" "S2Grid_find" "S2Grid_find_region" ...
  "SO3Grid_dist_region" "SO3Grid_find" "SO3Grid_find_region" ...
  "nfftmex" "fptmex" "nfsftmex" "nfsoftmex"
  ];

hasC = logical([1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 ]);

res = false(size(mexFiles));

wraptext([newline 'Mex files are compiled binaries that are used ' ...
  'within MTEX to speed up time critical computations. ' ...
  'As mex files are specific to different operating systems it is ' ...
  'not so easy for MTEX provide working binaries for different types ' ...
  'of systems.']);
disp([newline 'I''m now going to check all the mex files in' newline ...
  newline '  ' fullfile(mtex_path,'mex') newline newline ...
  'In case some of the mex files are not working, you have two options' newline ...
  ' 1. Use the command ' ...
  '<a href="matlab: mex_install(''force'')">mex_install</a> ' ...
  'to compile the mex files yourself' newline ...
  '    On a Mac this requires that you install XCode first.' newline ...  
  ' 2. Switch to a slower Matlab based implementation.' newline ...
  ]);
 
err = cell(length(mexFiles),1);
for k = 1:length(mexFiles)

  mexFile = mexFiles(k);
  
  fprintf(" checking: " + mexFile + "." + mexext);

  if ~exist(fullfile(mtex_path, "mex",mexFile + "." + mexext),'file')

    fprintf(" <strong>missing</strong>" + newline);

  else
    
    try
      res(k) = feval("check_" + mexFile);
    catch e
      err{k} = e;
    end
    if res(k)
      fprintf(" <strong>ok</strong>" + newline);
    else
      fprintf(" <strong>failed</strong>" + newline);
      if isempty(err{k})
        disp("  --> wrong result");
      else
        id = pushTemp(err{k});
        disp("  --> <a href=""matlab: rethrow(pullTemp(" + int2str(id) ...
          + "))"">" + err{k}.message + "</a>");
      end
    end
  end
end

disp(newline + "check complete" + newline)

% if ~all(res(hasC))
%   disp("Not all mex files are running. You might want to call" + newline + ...
%     "  <a href=""matlab: mex_install"">mex_install</a>" + newline + ...
%     "to compile the mex files yourself.");
%   if ismac
%     disp("On a Mac this requires to instal XCode first!" + newline)
%   end
% end

end

function out = check_insidepoly_dblengine

poly = [0.2 0.2; 0.7 0; 0.8 0.6; 0 1];

x = rand(10,1);
y = rand(10,1);

out = all(insidepoly(x,y,poly(:,1),poly(:,2)) == ...
  inpolygon(x,y,poly(:,1),poly(:,2)));

end

function out = check_jcvoronoi_mex %#ok<*DEFNU>

out = 1;

xy = rand(10,2);

[Vx,Vy,E1,E2,I_ED1,I_ED2] = jcvoronoi_mex(xy); %#ok<*ASGLU>


end

function out = check_EulerCyclesC

ebsd = mtexdata('small');
grains = calcGrains(ebsd('indexed')); %#ok<*NASGU>

gB = grains.boundary;

[g, c, cP] = EulerCyclesC(gB.I_FG,gB.F,length(gB.V));

out = 1;

end

function out = check_nfsftmex

S2F = S2Fun.smiley('exact');
S2FH = S2FunHarmonic(S2F);
S2G = equispacedS2Grid;
out = norm(S2F.eval(S2G) - S2FH.eval(S2G)) < 0.01;

end

function out = check_nfsoftmex

SO3F = unimodalODF(rotation.rand,'halfwidth',20*degree);
rot = SO3F.discreteSample(100000);
SO3F2 = calcDensity(rot,'halfwidth',5*degree,'nfsoft');
S3G = rotation.rand(10000);

out = norm(SO3F.eval(S3G) - SO3F2.evalNFSOFT(S3G)) ./ norm(SO3F.eval(S3G)) < 0.1;

end

function out = check_nfftmex

plan = nfft(1,32,100);
plan.f = rand(100,1);
plan.x = rand(100,1);
plan.nfft_adjoint;
delete(plan);
out = 1;

end

function out = check_fptmex
out = 1;
end


function out = check_wignerTrafomex

SO3F = SO3Fun.dubna;
SO3FH = SO3FunHarmonic(SO3F);
S3G = equispacedSO3Grid(SO3F.CS);
out = norm(SO3F.eval(S3G) - SO3FH.eval(S3G))/norm(SO3FH.eval(S3G)) < 0.01;

end

function out = check_wignerTrafoAdjointmex

S3F = @(rot) rot.angle;
S3FH = SO3FunHarmonic(S3F);
out = abs(norm(S3FH)-2.3)<1e-3;

end

function out = check_numericalSaddlepointWithDerivatives

out = 1;
S2F = BinghamS2([-1 0 1]);

end

function out = check_S1Grid_find

x = S1Grid([1,2,3,4,9],0,10);
out = find(x,3.2) == 3;

x = S1Grid([1,2,3,4,9,9.8],0,10,'periodic');

out = out && find(x,0.1) == 6;

end

function out = check_S1Grid_find_region

out = 1;

x = S1Grid([1,2,3,4,9],0,10);
find(x,4,5);

x = S1Grid([1,2,3,4,9,9.8],0,10,'periodic');

find(x,4,5);

x = S1Grid(0:39990,0,40000,'periodic');
y = linspace(0,39000,3000);


for i = 1:100, ind = find(x,y,50); end

for i = 1:1
  for j = 1:length(y)
    find(x,y(j),50);
  end
end


end


function out = check_S2Grid_find

x = equispacedS2Grid('points',5000);
y = vector3d(equispacedS2Grid('points',100));

tic
for i = 1:length(y)
  find(x,y(i));
end
t1 = toc;

tic
for i = 1:100
  find(x,y);
end
t2 = toc;

out = 1;

end

function out = check_S2Grid_find_region

%x = equispacedS2Grid('points',5000);
%plot(subGrid(x,find(x,xvector,10*degree)));

x = equispacedS2Grid('points',5000);
y = vector3d(equispacedS2Grid('points',100));

tic
for i = 1:length(y)
  find(x,y(i),0.5);
end
t1 = toc;

tic
for i = 1:100
  find(x,y,0.5);
end
t2 = toc;

out = 1;

end

function out = check_SO3Grid_dist_region

cs = crystalSymmetry('432');
S3G = equispacedSO3Grid(cs,'resolution',2*degree);

ori = orientation.rand(cs);

d1 = angle_outer(S3G,ori,'epsilon',10*degree);
d2 = angle_outer(S3G,ori);

out = all(isnull(d2(d2< 5*degree) - d1(d2 < 5*degree)));

end

function out = check_SO3Grid_find_region

cs = crystalSymmetry('432');
S3G = equispacedSO3Grid(cs,'resolution',2*degree);

ori = orientation.rand(cs);

i = find(S3G,ori,10*degree);

d = angle(S3G,ori) < 10*degree;

out = all(d == i);

end

function out = check_SO3Grid_find

cs = crystalSymmetry('432');
S3G = equispacedSO3Grid(cs);

ori = orientation.byEuler(41*degree,31*degree,40*degree,cs);

%ori = orientation.rand(cs);

i = find(S3G,ori);

d = angle(S3G,ori);

out = min(d(:))==d(i);

end


function xxxx
cs = crystalSymmetry('trigonal');
ss = specimenSymmetry('1');

x = equispacedSO3Grid(cs,ss,'points',100000);
y = equispacedSO3Grid(cs,ss,'points',100000);


tic
dot_outer(x,y,'epsilon',5*degree);
toc

tic
find(x,quaternion(y),'epsilon',5*degree);
toc

find(x,quaternion.id,20*degree)

q = axis2quat(xvector+yvector,45*degree);
q = quaternion.id;

sx = quaternion(subGrid(x,find(x,q,10*degree)));

dist(cs,specimenSymmetry,q,sx) / degree


plot(inv(sx)*xvector)
plot(inv(sx)*yvector)
plot(inv(sx)*zvector)


A = cos(ay)*cos(cy)*cos(ax)*(cos(by)*cos(bx)-1) - ...
  sin(ay)*sin(cy)*cos(ax)*(cos(bx)-cos(by));

B = cos(ay)*cos(cy)*cos(ax)*(cos(by)*cos(bx)-1) - ...
  sin(ay)*sin(cy)*cos(ax)*(cos(bx)-cos(by));

end