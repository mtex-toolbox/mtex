%% The class EBSD
%
%% Abstract
% class representing single orientation measurements
%
%% Contents
%
%% Description
%
% An object of the class Polefigure represents experimental or sythetic 
% EBSD data, i.e. a list of oreintations togehter with a crystal and a
% specimen symmetry. EBSD data can be either important from data - files
% (see: [[interfacesEBSD_index.html,EBSD interfaces]]) or simulated from 
% [[ODF_index.html,ODFs]]. There is a large set of tools to analyse and 
% modify pole figure data (see below).
%
%% Importing EBSD data
%
% The typical way to import pole figure data is to specify the parameter
%
%   cs       - crystal [[symmetry_index.html,symmetry]]
%   ss       - specimen [[symmetry_index.html,symmetry]]
%   fname    - a file name (or a list of filenames)
%
% an to use the command [[loadEBSD.html,loadEBSD]] to import
% the data. For detailed information how importing pole figure data see
% [[interfacesEBSD_index.html,EBSD inteerfaces]].

cs = symmetry('-3m',[1.2 1.2 3.5]); % crystal symmetry
ss   = symmetry('triclinic');        % specimen symmetry

fnames = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

ebsd_i = loadEBSD(fnames,cs,ss,'header',1,...
  'ColumnNames',{'Euler 1','Euler 2','Euler 3','x','y'},'Columns',[5,6,7,3 4])

%%
% a second way to define EBSD data is to simulate them using a given
% ODF. This is done by the command 
% [[ODF_simulateEBSD.html,simulateEBSD]]

ebsd_s = simulateEBSD(santafee,10000)

%% Modify EBSD
%
% Single EBSD data sets can be joined to a single variable using

ebsd = [ebsd_i,ebsd_s] 

%%
% Additional features of the MTEX toolbox include to rotate EBSD 
% data.

ebsd_rotated = rotate(ebsd_s,axis2quat(xvector-yvector,25*degree));

    
%% Plotting EBSD data
%
% The typical way of plotting EBSD data is to asign a color to each
% orientation and plot a map of these colors.

plot(ebsd_i)

%%
% EBSD data can also be plotted using the [[EBSD_plotpdf.html,plotpdf]] command.
% It plottes the application of the orientations stored in the EBSD object
% to a certain crystal direction as a scatter plot - which can be
% interpreted as a pole figure.

close; figure('position',[100 100 400 300])
plotpdf(ebsd_i,Miller(1,0,0,cs),'points',300,'MarkerSize',3)   % plot EBSD data

%% ODF - estimation
%
% Using kernel density estimation EBSD data can be used to calculate an
% ODF. This is done by the command [[EBSD_calcODF.html,calcODF]] 

odf = calcODF(ebsd_i,'halfwidth',10*degree)
plotpdf(odf,Miller(1,0,0,cs),'antipodal')

%% Demo
%
% For a more exausive description of the EBSD class have a look at the 
% [[ebsd_demo.html,EBSD demo]]!
% 
