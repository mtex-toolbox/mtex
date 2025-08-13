function display(v,varargin)
% standard output

if check_option(varargin,'onlyShowVectors')
  display@vector3d(v,varargin{:})
  return
end

v.opt.TagentSpace = v.tangentSpace;

displayClass(v,inputname(1),'moreInfo',char(v.how2plot,'compact'),varargin{:});

disp( [' intern symmetries: ' char(v.hiddenCS,'compact') ' ' char(8594) ' ' char(v.hiddenSS,'compact')] );

display@vector3d(v,varargin{:},'skipHeader')
