%% Test quadrature for all specimen and crystal symmetries

% ohne antipodal und ohne isReal
clear
rng(0)
F = SO3Fun.dubna;
F.CS=crystalSymmetry;
F = F + SO3FunRBF(orientation.rand(5e2),SO3DeLaValleePoussinKernel);
r=rotation.rand(1e3);

%load('quadtest.mat')
%N = quad;
N = nan(45,45,4,30);

bwmin = 11;
bwmax = 11;
for bw = bwmin:bwmax
for symcase=1:4
for isl=[1,3,6,9,12,17,19,22,25,28,32,36,41,43]

% s = (bw-bwmin)*4*45 + (symcase-1)*45 + isl;
% tmp = sprintf('Please wait... %.2f%% [%d/%d]\n', s/((bwmax-bwmin+1)*4*45)*100 , s , (bwmax-bwmin+1)*4*45);
% fprintf('%s',tmp)

for isr=[1,3,6,9,12,17,19,22,25,28,32,36,41,43]

  switch symcase
    case 1
      SRight = specimenSymmetry('PointId',isr);
      SLeft = specimenSymmetry('PointId',isl);
    case 2
      SRight = crystalSymmetry('PointId',isr);
      SLeft = crystalSymmetry('PointId',isl);
    case 3
      SRight = crystalSymmetry('PointId',isr);
      SLeft = specimenSymmetry('PointId',isl);
    case 4
      SRight = specimenSymmetry('PointId',isr);
      SLeft = crystalSymmetry('PointId',isl);     
  end
  
  A=F;
  A.bandwidth = bw;
  A.CS = SRight; A.SS = SLeft;
  A = SO3FunHarmonic(A);          %A.eval(A.CS.rot*r(1)*A.SS.rot)
  %try
 %   warning off
    SO3F = SO3FunHarmonic.quadrature(A,'bandwidth',bw);
    N(isl,isr,symcase,bw) = max(abs(SO3F.eval(r)-A.eval(r)));
%    warning on
  %end
end

% fprintf('%s',char(sign(tmp)*8))  

end
end
end


%v=(N([1,3,6,9,12,17,19,22,25,28,33,36,41,43],[1,3,6,9,12,17,19,22,25,28,33,36,41,43],:,bw)>1e-3)

% 
% figure(1)
% subplot(221)
% spy(N(isl,isr,2,:)>1e-3)
% subplot(222)
% spy(N(isl,isr,4,:)>1e-3)
% subplot(223)
% spy(N(isl,isr,3,:)>1e-3)
% subplot(224)
% spy(N(isl,isr,1,:)>1e-3)

% for k=1:30
% k
% spy(isnan(N(:,:,:,k)) | N(:,:,:,k)>1e-3)
% pause(0.5)
% end