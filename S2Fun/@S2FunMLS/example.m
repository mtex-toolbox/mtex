function sF = example(varargin)
% Construct example for an S2FunTri.

      odf = SantaFe;
      v = equispacedS2Grid;
      values = odf.calcPDF(Miller(1,0,0,odf.CS),v);
      
      sF = S2FunMLS(v,1i*values);

end