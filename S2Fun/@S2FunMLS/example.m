function sF = example(varargin)
% Construct an example for an S2FunMLS.

odf = SantaFe;
v = equispacedS2Grid('points',1000);
values = odf.calcPDF(Miller(1,0,0,odf.CS),v);

sF = S2FunMLS(v,values);

end
