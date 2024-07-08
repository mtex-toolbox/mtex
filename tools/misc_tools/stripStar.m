function [c,hD,vD,hDi,vDi,mvD,modeD,b]=stripstAr(g,bins,varargin)
% This function determines a distribution of 3D sphere diameters
% from a list of 2d grain diameters, based on stripstar, by Renee Heilbronner
% and astrip by Ondrej Lexa.
%
% Syntax
%   [c,hD,vD,hDi,vDi,mvD,modeD,b]=stripstar(g,bins);
%
% Input
%   g      - grain diamteres (eq. diameter)
%   bins   - vector of right edges
%
% Output
%   c      - bin centers
%   hD     - 3d frequencies
%   vD     - volume fractions
%   hDi    - 3d frequencies including antispheres
%   vDi    - volume fractions including antispheres
%   mvD    - vol weighted mean of vD
%   modeD  - mode of vD
%   b      - input bins
%
% Options
%   nohist - do not plot a histogram
%   mplot  - plot density distribution of vD

% bins and bincenters
b= reshape(bins,1,length(bins));
nbins=length(bins)-1;
ded=diff(b);
c=cumsum([b(1)+ded(1)/2 ded(2:end)])';

% make a re hist
n=histc(g,b);
n(end-1)=n(end-1)+n(end);
n(end)=0;
na=n(1:end-1)';

V=zeros(nbins);
% strip it back for uniform distribution
for i=1: nbins
    for j=i: nbins
        V(i,j)=(sqrt(j^2-(i-1)^2)-sqrt(j^2-i^2))/j;
    end
end

for i=1:nbins
    V(:,i)= V(:,i)/nbins*i;
end

% prep output
hD=inv(V)*na';
vD=c.^3.*hD;

hDi=100*hD/sum(abs(hD));
vDi=100*vD/sum(abs(vD));

hD(hD<0)=0;
vD(vD<0)=0;

hD=100*hD/sum(hD);
vD=100*vD/sum(vD);

mvD=sum((c'*vD))/sum(vD);
modeD = getModalGs(c,vD);

% eventually plot some histograms
ptype = 0;
if isempty(varargin) | ~strcmpi(varargin{1},'nohist')
    ptype = 1; end

if ~isempty(varargin) & strcmpi(varargin{1},'mplot')
    ptype = 2; end


switch ptype
    case 0
        return;

    case 1      % simple histogram plot incl. input, output and antipheres 
        subplot(1,3,1)
        bar(c,[hDi vDi],1);
        xlabel('equivalent diameter');
        ylabel('%');
        legend({'3D diameter','Volume fraction'});
        title('3D diameters incl. antispheres')
        set(gca,'FontSize',18)
        subplot(1,3,2)
        bar(c,[hD vD],1);
        xlabel('equivalent diameter');
        ylabel('%');
        legend({'3D diameter',['Volume fraction mean=' num2str(round(mvD*10)/10)]});
        title('3D diameters')
        set(gca,'FontSize',18)
        subplot(1,3,3)
        bar(c,n(1:end-1));
        xlabel('equivalent diameter');
        ylabel('counts');
        rms2d = rms(g);
        legend({['2D diameters:' newline ...
            'rms = ' num2str(round(rms2d,1))]});
        title('2D input')
        set(gca,'FontSize',18)


    case 2      % plot volume weighted 3d and density estimation
        varargin =  delete_option(varargin,'mplot');
        modeD = getModalGs(c,vD,[{'plot'},varargin{:}]);

end

    function modeD = getModalGs(c,vD,varargin)
        gstd=(c(3)-c(1)); %TODO
        gh = @(m,x) Gaussian(m,gstd,x);
        x = linspace(0,1.5*max(c),1000);
        sdiam = sum(vD.*gh(c,x));
        [~,mpos] = max(sdiam);
        modeD=x(mpos);
        if ~isempty(varargin) & check_option(varargin{:},'plot')
            opts =  delete_option(varargin{:},'plot');
            plot(x,sdiam/trapz(x,sdiam),opts{:})
            legend(['kde vD (mode =' num2str(round(modeD,2)) ')']);
            xlabel('equivalent diameter');
            ylabel('p');
            title('3D diameters kde')
            set(gca,'FontSize',18)
            xlim([0,max(c)*1.05])
        end
    end


end

