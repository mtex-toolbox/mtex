function SO3F = transformReferenceFrame(SO3F,cs)
% change reference frame of an ODF
%
% Input
%  odf - @SO3Fun
%  cs  - new @crystalSymmetry
%
% Output
%  odf - @SO3Fun
%
% Example
%
% cs1 = crystalSymmetry('121',[1 3 2]);
% cs2 = crystalSymmetry('112',[2 1 3]);
%
% ori = orientation.rand(cs1)
% odf1 = SO3FunHarmonic(unimodalODF(ori))
% %odf1 = BinghamODF([1 0 0 0],ori)
% %odf1 = SO3FunHandle(@(ori) odf1.eval(ori),odf1.CS)
% odf2 = transformReferenceFrame(odf1,cs2)
%
% plotPDF(odf1,Miller({1,0,0},{0,0,1},{0,1,0},cs1))
% nextAxis(2,1)
% plotPDF(odf2,Miller({0,1,0},{1,0,0},{0,0,1},cs2))
%

if SO3F.CS ~= cs
    
  M = transformationMatrix(SO3F.CS,cs);
  mori = orientation.byMatrix(M,SO3F.CS,cs);
  
  SO3F = rotate(SO3F,inv(mori),'right');
  
end
