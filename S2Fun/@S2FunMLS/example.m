function sF = example(varargin)
% Construct example for an S2FunTri.

      odf = SantaFe;
      v = equispacedS2Grid('points',1000);
      values = odf.calcPDF(Miller(1,0,0,odf.CS),v);
      
      sF = S2FunMLS(v,values);

end