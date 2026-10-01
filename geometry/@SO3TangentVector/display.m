function display(v,varargin)
% standard output

if check_option(varargin,'onlyShowVectors')
  display@vector3d(v,varargin{:})
  return
end

v.opt.tangentSpace = v.tangentSpace;

ref = v.oriRef;
displayClass(v,inputname(1),'moreInfo',referenceFrame.headerChar(v.frame,v.how2plot,ref.CS),varargin{:});

disp( [' intern symmetries: ' char(ref.CS,'compact') ' ' char(8594) ' ' char(ref.SS,'compact')] );

display@vector3d(v,varargin{:},'skipHeader')
