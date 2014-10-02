function q = maxpdf( odf,h, varargin)
% returns the maximum orientation in a polefigure
%
% Input
%  odf - @ODF
%  h   - @Miller
%
%
%

argin_check(h,'Miller');
h = odf.CS.ensureCS(h);

for k=1:length(h)
  
  res = 5*degree;
  
  % try to find the maximum value for P(h,r)
  S2 = equispacedS2Grid('resolution',res);
  
  while res/2 > 0.25*degree
    
    res = res/2;
    f = odf.calcPDF(h(k),S2);
    
    [a, i] = max(f);
    
    %local search
    v = vector3d(S2(i));
    S2 = hr2quat(zvector,v)*equispacedS2Grid('maxtheta',4*res,'resolution',res);
    
  end
  
  % choose the maximum density of the fibre G(h,r)
  g = fibre2quat(h(k),v,'resolution',0.25*degree);
  f = eval(odf,g);
  
  [a, i] = max(f);
  q(k) = g(i);
  
end

