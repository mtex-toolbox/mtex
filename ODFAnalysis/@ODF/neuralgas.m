function S2G = neuralgas(odf,h,varargin)
% attempt to distribute measure-sites equally according to invers polefigure density (experimental)
%
% Syntax
%   S2G = neuralgas(odf,Miller(1,0,0,cs),'points',500,'epoches',25)
%
% Input
%  odf - @ODF
%  h   - @Miller
%
% Options
%  Grid    - @S2Grid, reference Grid to evaluate PDF
%  resolution - Grid Resolution
%  maxtheta - max Theta of Grid
%  Points  - number of Points
%  epoches - number of Iterations
%  eta     - 'learing--rate' as vector: [eta_start eta_stop], default [0.1 0.02]
%  lambda  - stimuli of 
%  verbose - display points during optimisation
%
% See also
% S2Grid/refine


argin_check(odf,'ODF');
argin_check(h,'Miller');

if length(h)>1, warning('only perceeding with first Miller indice'), end

if check_option(varargin,'verbose'), verb = true; else verb = false; end

r = get_option(varargin,'Grid',...
  equispacedS2Grid('resolution',get_option(varargin,'resolution',2*degree),...
  'upper','maxtheta',get_option(varargin,'maxtheta',70*degree)));

v = double(vector3d(r));
v = reshape(v,[],3);

P = odf.calcPDF(h,r);

nr = length(r);
nx = fix(get_option(varargin,'Points',100));
W = v(randi(nr,nx,1),:);

eta = get_option(varargin,'eta',[0.1 0.02]);
lambda = get_option(varargin,'lambda',[nx*2 0.01]);

tmax = nr*get_option(varargin,'epoches',50);

e = @(t) eta(1).*(eta(2)/eta(1)).^(t./tmax);
l = @(t) lambda(1).*(lambda(2)/lambda(1)).^(t./tmax);
e = e(1:tmax);
l = l(1:tmax);

kk = (0:nx-1)';
 
smpl = fix(rand(1,tmax)*(nr-1))+1;


for t=1:tmax
  sm = smpl(t);
  d = v(sm,:); %random sample
  p = P(sm).^2; %and its density
  
  dst = pi-W*d';% pseudo distance
%   dst = acos(W*d');
  
  [dst k] = sort(dst);  
  W = W(k,:); %sort vectors
  
  dw = e(t).*exp(-kk./(p*l(t))); % probabilistic distance stimuli
  % dw = p.^2.*exp(-kk./l(t));
  
  % update direction
  W(:,1) = W(:,1) + dw.*(d(1) - W(:,1)); 
  W(:,2) = W(:,2) + dw.*(d(2) - W(:,2));
  W(:,3) = W(:,3) + dw.*(d(3) - W(:,3)); 
  
  %vector normalisation on unit sphere
  nrm = sqrt(W(:,1).^2 + W(:,2).^2 + W(:,3).^2);
  
  W(:,1) = W(:,1)./nrm;
  W(:,2) = W(:,2)./nrm; 
  W(:,3) = W(:,3)./nrm; 
      
  if verb && ~mod(t,500)
    plot(S2Grid(vector3d(W')),'upper');
    drawnow
  end  
end

S2G = S2Grid(vector3d(W'));


if verb 
  plotPDF(odf,h,'upper');
  hold on, 
  plot(S2G);
end
