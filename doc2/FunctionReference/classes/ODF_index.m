%% Orientation Density Functions (The Class @ODF)
% This sections describes the class *ODF* and gives an overview how to work
% with orientation density functions in MTEX.
%
%% Class Description
% ODFs are at the very heart of MTEX. Almost any computation in MTEX can be
% done by estimating ODFs from various data, analyzing model ODFs,
% simulating experimental data from ODFs, or calculating any texture
% characteristics from an ODF. The following mindmap may give you an idea
% what is possible in MTEX.
%
% <<odf.png>>
% 
%% SUB: Model ODFs
%
% MTEX provides a very simple way to define model ODFs, e.g. unimodal ODFs,
% fibre ODF, Bingham ODFs or ODFs specified by Fourier
% coefficients. The central idea is that MTEX allows you to calculate with
% ODF as with ordinary number. That is you can multiply and ODF with a
% certain number, you can add, subtract or rotate ODFs. More precise
% information how to work with model ODFs in MTEX can be found in the
% section <ModelODFs.html ModelODFs>. 
%


%% SUB: Estimating ODFs from EBSD Data or Pole Figure Data
%
% The second natural way how ODFs occurs in MTEX is by estimating them from
% EBSD or pole figure data. It should be stressed that for MTEX there is no
% estimated ODFs and difference between model ODFs and estimated ODF. That
% means any operation that is valid for model ODFs is valid for estimated
% ODFs as well. More information how to estimate ODFs can be found in the
% sections <EBSD2odf.html ODF estimation from EBSD data> and
% <PoleFigure2odf.html ODF estimation from Pole Figure data>.
%
%% SUB: Analyzing ODFs
%
% MTEX provides a lot of tools to make analyzing and interpreting ODFs as
% simple as possible. The tools may be split into two groups - texture
% characteristics and visualization tools.
%
% <<odf2.png>>
%
% Have a look at the sections <ODFCalculations.html ODF Calculations>  and
% <ODFPlots.html ODF plots> for more information. 

