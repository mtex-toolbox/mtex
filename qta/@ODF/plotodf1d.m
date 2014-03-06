function plotodf1d(odf,varargin)
% plot odf
%
% Plots the ODF as one dimensional sections
%
%% Input
%  odf - @ODF
%
%% Options
%  CENTER     - for radially symmetric plot
%  AXES       - for radially symmetric plot
%
%% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 


center = get_option(varargin,'CENTER',quaternion(1,0,0,0),{'quaternion','rotation','orientation'});
axes = get_option(varargin,'AXES',[xvector,yvector,zvector]);

omega = linspace(-pi,pi,200);
for i=1:length(axes)
  q = axis2quat(axes(i),omega);
  d(:,i) = eval(odf,q*center,varargin{:}); %#ok<EVLC,AGROW>
end
optionplot(omega,d,varargin{:});
xlim([-pi pi]); xlabel('omega')
legend(arrayfun(@(v) char(axes(v)),1:length(axes),'UniformOutput', false));
