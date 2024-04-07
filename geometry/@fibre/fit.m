function [f,lambda,delta] = fit(ori,varargin)
% determines the fibre that fits best a list of orientations
%
% Syntax
%   f = fibre.fit(ori) % fit fibre to a list of orientations
%
%   f = fibre.fit(ori,'local') 
%
%   f = fibre.fit(odf) % fit fibre to a list of orientations
%
% Input
%  ori1, ori2, ori - @orientation
%  odf - @SO3Fun
%
% Output
%  f       - @fibre
%  lambda  - eigenvalues of the orientation tensor
%
% Options
%  local   - fast approach for locally concentrated orientations 
    
if isa(ori,'SO3Fun')

  odf = ori;
  cs = odf.CS.properGroup;
    
  hGrid = Miller(equispacedS2Grid('resolution',10*degree,...
    cs.fundamentalSector),cs);
  rGrid = equispacedS2Grid('resolution',1.25*degree,odf.SS.fundamentalSector);
  lGrid = equispacedS2Grid('resolution',0.5*degree,'maxTheta',10*degree);
  
  % search through all pole figures
  v = -inf;
  for ih = 1:length(hGrid)
    
    % detect maximum in pole figure
    [~,ir] = max(calcPDF(odf,hGrid(ih),rGrid));
  
    % detect local maximum in corresponding inverse pole figure
    lhGrid = rotation.byAxisAngle(zvector + hGrid(ih),pi) * lGrid;
    [~,ih2] = max(calcPDF(odf,lhGrid,rGrid(ir)));
  
    % detect local maximum in corresponding pole figure - second iteration
    lrGrid = rotation.byAxisAngle(zvector + rGrid(ir),pi) * lGrid;
    [vTmp,ir2] = max(calcPDF(odf,lhGrid(ih2),lrGrid));

    % maybe we have found a new optimum
    if vTmp > v
      f = fibre(Miller(lhGrid(ih2),odf.CS),lrGrid(ir2));
      v = vTmp;
    end

  end
  return

elseif check_option(varargin,{'noSymmetry','local'}) || ori.CS.numProper==1
  
  [~,~,lambda,eigv] = mean(ori,varargin{:});
  
  ori12 = orientation(quaternion(eigv(:,4:-1:3)),ori.CS,ori.SS);
  f = fibre(ori12(1),ori12(2),'full',varargin{:});
  
  if nargout == 3
    delta = norm(angle(f,ori)) / length(ori);
  end

  return
  
end

% the global approach
odf = calcDensity(ori,'halfwidth',10*degree);
cs = ori.CS.properGroup;
rotSym = cs.rot;
fs = cs.fundamentalSector;
  
hGrid = Miller(equispacedS2Grid('resolution',10*degree,fs),cs);
rGrid = equispacedS2Grid('resolution',1.25*degree,ori.SS.fundamentalSector);
% a local grid
lGrid = equispacedS2Grid('resolution',0.5*degree,'maxTheta',10*degree);
%localhGrid = [localhGrid;-localhGrid];
  
% search through all pole figures
v = inf;
for ih = 1:length(hGrid)
    
  % detect maximum in pole figure
  [~,ir] = max(calcPDF(odf,hGrid(ih),rGrid));
  
  % detect local maximum in corresponding inverse pole figure
  lhGrid = rotation.byAxisAngle(zvector + hGrid(ih),pi) * lGrid;
  [~,ih2] = max(calcPDF(odf,lhGrid,rGrid(ir)));
  
  % project to fibre
  d = angle_outer(times(rotSym,lhGrid(ih2),1), times(inv(ori),rGrid(ir),0),'noSymmetry');
  [m,idSym] = min(d,[],1);
  
  % robust estimate
  oriP = times(ori(m<quantile(m,0.8)), rotSym(idSym(m<quantile(m,0.8))),0);
  %oriP = times(ori, rotSym(idSym),0);
  
  % fit fibre
  fTmp = fibre.fit(oriP,'noSymmetry');
  %fTmp = fibre(Miller(rhGrid(id2),ori.CS),rGrid(id));
  
  % maybe we have found a new optimum
  vTmp = mean(angle(fTmp,ori));
  if vTmp < v, f = fTmp; v = vTmp; end
  
end

function test %#ok<DEFNU>
    
  cs = crystalSymmetry('432');
  f = fibre.rand(cs);
  odf = fibreODF(f,'halfwidth',20*degree);
  
  ori = discreteSample(odf,100000);
  
  tic
  fRec = fibre.fit(ori,'refine') %#ok<NOPRT>
  toc
  
  mean(angle(fRec,ori))./degree %#ok<NOPRT>
  
  mean(angle(f,ori))./degree %#ok<NOPRT>
  
  angle(fRec,f)./degree %#ok<NOPRT>
  
end

end