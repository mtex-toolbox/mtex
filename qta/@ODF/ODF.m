classdef ODF < matlab.mixin.Heterogeneous
  
  properties
    CS = symmetry('-1'); % crystal symmetry
    SS = symmetry('-1'); % specimen symmetry
    weight = 1; % weight
    file_name = [];
  end
  
  methods
    function odf = ODF(varargin)
      
      % copy constructor
      if nargin > 0 && isa(varargin{1},'ODF')
        odf.CS = varargin{1}(1).CS;
        odf.SS = varargin{1}(1).SS;
      end
      
      % extract crystal and specimen symmetry
      isCS = cellfun(@(x) isa(x,'symmetry'),varargin);
      if any(isCS), odf.CS = varargin{find(isCS,1,'first')};end
      if sum(isCS)>1, odf.SS = varargin{find(isCS,1,'last')};end
      
    end
  end
  
  methods(Abstract,Access=protected)
    f = doEval(odf,g,varargin)
    Z = doPDF(odf,h,r,varargin)    
    odf = doRotate(odf,q,varargin)
    f_hat = doFourier(odf,L,varargin)
    doDisplay(odf)
    %odf = doRotate(odf,q,varargin)
  end
  
  methods(Access=protected)
    ori = discreteSample(odf,npoints,varargin)
    mdf = doMDF(odf1,odf2,varargin)
    [TVoigt, TReuss] = doMeanTensor(odf,T,varargin)
    [v,S3G] = doVolume(odf,center,radius,S3G,varargin)
  end
  
  methods(Sealed)

    [density,omega] = calcAngleDistribution(odf,varargin)
    x = calcAxisDistribution(odf,h,varargin)
    v = calcAxisVolume(odf,axis,radius,varargin)    
    ebsd = calcEBSD(odf,points,varargin)
    e = calcError(odf1,odf2,varargin)
    f_hat = calcFourier(odf,L,varrgin);
    mdf = calcMDF(odf1,varargin)
    [modes, values] = calcModes(odf,varargin)
    pf = calcPoleFigure(odf,h,varargin)
    [TVoigt, TReuss, THill] = calcTensor(odf,T,varargin)
    [odf,r,v1,v2] = centerSpecimen(odf,center,varargin)
    s = char(odf)
    odf = diff(odf1,odf2,varargin)
    display(odf,varargin)
    e = entropy(odf,varargin)
    f = eval(odf,g,varargin)
    export(odf,filename,varargin)
    export_generic(odf,filename,varargin)
    export_mtex(odf,filename,varargin)
    export_VPSC(odf,filename,varargin)
    v = fibreVolume(odf,h,r,radius,varargin)
    varargout = get(obj,vname,varargin)
    hist(odf,varargin)
    [m,ori]= max(odf,varargin)
    q = maxpdf( odf,h, varargin)
    [m kappa v] = mean(odf,varargin)
    odf = minus(o1,o2)
    odf = mrdivide(odf,s)
    t = norm(odf,varargin)
    Z = pdf(odf,h,r,varargin)    
    plot(odf,varargin)
    plotAngleDistribution(odf,varargin)
    plotAxisDistribution(odf,varargin)
    plotDiff(odf1,odf2,varargin)
    [x,omega] = plotFibre(odf,h,r,varargin)
    plotipdf(odf,r,varargin)
    plotodf(odf,varargin)
    plotodf1d(odf,varargin)
    plotpdf(odf,h,varargin)
    odf = plus(o1,o2)
    S3G = quantile(odf,varargin)
    odf = rdivide(odf,s)
    odf = rotate(odf,q,varargin)
    obj = set(obj,vname,value,varargin)
    Z = slope(odf,h,r,varargin)
    odf = smooth(odf,varargin) %TODO
    t = textureindex(odf,varargin)
    odf = times(x,y)
    [I, odf] = transinformation(odf1,odf2,varargin)
    odf = uminus(odf)
    v = volume(odf,center,radius,varargin)
  end
  
end
