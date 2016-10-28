function plot3d(odf,varargin)
% plots odf

if odf.antipodal, ap = {'antipodal'}; else ap = {}; end
oS = newODFSectionPlot(odf.CS,odf.SS,ap{:},'phi2','secResolution',2.5*degree,varargin{:});

S3G = oS.makeGrid('resolution',2.5*degree,varargin{:});

% bounds
[theta,rho] = polar(oS.plotGrid);
theta = repmat(theta,1,1,length(oS.phi2));
rho = repmat(rho,1,1,length(oS.phi2));
phi2 = repmat(reshape(oS.phi2,[1,1,length(oS.phi2)]),...
  [size(oS.plotGrid) 1]);
     
% get contours
contours = get_option(varargin,{'surf3','contour3'},10,'double');

contour3s(rho./degree,theta./degree,phi2./degree,odf.eval(S3G),contours,...
  'surf3',varargin{:},'xlabel','$\varphi_1$','ylabel','$\Phi$','zlabel','$\varphi2$');

setappdata(gca,'projection','Bunge');
fcw;

end
