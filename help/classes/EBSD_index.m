%% The class EBSD
% class representing single orientations
% 
%% Description
%
% An object of the class Polefigure represents experimental or sythetic 
% pole figure data, i.e. numeric data indexed by crystal and specimen
% directions. Pole figure data can be either important from data - files
% (see: [[interfaces_index.html,interfaces]]) or simulated from 
% [[ODF_index.html,ODFs]]. There is a large set of tools to analyse and 
% modify pole figure data (see below).
%
%% Importing pole figures
%
% The typical way to import pole figure data is to specify the parameter
%
%   cs       - crystal [[symmetry_index.html,symmetry]]
%   ss       - specimen [[symmetry_index.html,symmetry]]
%   fnames   - a list containing the filenames 
%
% an to use the command [[loadPoleFigure.html,loadPoleFigure]] to import
% the data. For detailed information how importing pole figure data see
% [[interfaces_index.html,inteerfaces]].

cs = symmetry('-3m',[1.2 1.2 3.5]); % crystal symmetry
ss   = symmetry('tricline');        % specimen symmetry

fnames = [mtexDataPath '/ebsd/test.txt'];

ebsd = loadEBSD(fnames,cs,ss)

%%
% a second way to define pole figure data is to simulate the using a given
% ODF. This is done by the command 
% [[ODF_simulateEBSD.html,simulateEBSD]]

pfs = simulateEBSD(santafee,10000)

%% Modify pole figures
%
% Pole figures corresponding to different crystal directions my be stored
% in one variable. In this case they are index by

pfi(1) % pole figure to the first crystal direction
pfi(2) % pole figure to the second crystal direction

%%
% Single pole figures can be joined to a single variable using

pfi = [pfi(2),pfi(1)] % this reorders the crystal directions in pf

%%
% Furthermore, you are allowed to calculate with pole figures as with 
% ordinary numbers, i.e. you can use the operators "*", "+", "-" the to 
% scale, add or subtract pole figure data. 

pf = 2*pfi(1) + 5*pfi(2);

%%
% Additional features of the MTEX toolbox include to rotate pole figure or
% to delte or modify specific data values by conditions on the specimen
% directions.

pf_modifies = delete(pf, ...
  getTheta(getr(pf))>=70*degree & ...
  getTheta(getr(pf))<=75*degree);

pf_rotated = rotate(pf,axis2quat(xvector-yvector,25*degree));

%% Analyze Pole Figures
%
% For the statistical analysis of pole figures several methods exists. 

min(pfi);
max(pfi);
close; figure('position',[100,100,500,300])
hist(pfi)

    
%% Plotting PoleFigures
%
% Pole figures are plotted using the [[PoleFigure_plot.html,plot]] command.
% It plottes a singe colored dot for any data point contained in the pole
% figure. 

clf; set(gcf,'position',[100 100 400 300])
plot(pf)   % plot pole figure data
