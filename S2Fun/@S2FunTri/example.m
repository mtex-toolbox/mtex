function sF = example(varargin)
% Construct example for an S2FunTri.

      %mtexdata dubna;
      
      %sF = S2Fun(pf({1}).r,pf({1}).intensities);
      
      %plot(sF,'upper');
       
      odf = SantaFe;
      
      v = equispacedS2Grid('points',1000);
      
      values = odf.calcPDF(Miller(1,0,0,odf.CS),v);
      
      sF = S2FunTri(v,values);
      
end