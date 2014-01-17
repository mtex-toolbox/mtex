%% Template Example
% <author:fl.bachmann@googlemail.com F. Bachmann> 
% Template scripting allows a standard way of analysing just imported data,
% e.g. for a frequently used manner.
%
%   mtex_path/templates/ (TYPE_) custom template name (.m)
%
% This script will be appended when choosen from the import wizard.
% Nevertheless writing a template for any type of Data (PoleFigure, EBSD,
% ODF) has two standard variables names
%
%   CS - Crystal Symmetry
%   SS - Specime Symmetry
%
% furthermore the Data gets a variable according to its type
%
%   pf   - PoleFigure
%   ebsd - EBSD
%   odf  - ODF
%
%% Code begins here

plot(pf)