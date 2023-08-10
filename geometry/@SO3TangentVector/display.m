function display(v,varargin)
% standard output

if check_option(varargin,'onlyShowVectors')
  display@vector3d(v,varargin{:})
  return
end

v.opt.TagentSpace = v.tangentSpace;

displayClass(v,inputname(1),varargin{:});%...
  %'moreInfo',char(v.refSystem,'compact'),varargin{:});

display@vector3d(v,varargin{:},'skipHeader')
