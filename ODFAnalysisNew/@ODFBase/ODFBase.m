classdef ODFBase
     
  methods
    
  end
  
  methods (Static = true)

    [odf,interface,options] = load(fname,varargin)
    
    [odf,resvec] = interp(ori,values,varargin)
    
    function odf = ambiguity1(varargin)

      cs = crystalSymmetry('222');

      orix = orientation.byAxisAngle(xvector,90*degree,cs);
      oriy = orientation.byAxisAngle(yvector,90*degree,cs);
      oriz = orientation.byAxisAngle(zvector,90*degree,cs);

      odf = unimodalODF([orix,oriy,oriz],varargin{:});
    end

    function odf = ambiguity2(varargin)
      cs = crystalSymmetry('222');
      ori = orientation.byAxisAngle(vector3d(1,1,1),[0,120,240]*degree,cs);
      odf = unimodalODF(ori,varargin{:});
    end
    
  end
     
end
