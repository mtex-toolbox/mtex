function [pf,interface,options,ipf] = loadPoleFigure(fname,varargin)
% import pole figure data 
%
%% Description
% *loadPoleFigure* is a high level method for importing pole figure data
% from external files. It autodetects the format of the file. As parameters
% the method requires the crystal and specimen @symmetry. Additionally it is
% sometimes required to pass a list of crystal directions and a list of
% structure coefficients. See [[ImportPoleFigureData.html,interfaces]] for an
% example how to import superposed pole figures. In the case of generic
% ascii files each of which consist of a table containing in each row a
% specimen direction and a diffraction intensity see
% [[loadPoleFigure_generic.html,loadPoleFigure_generic]] for additional options.
% Furthermore, you can specify a comment to be associated with the data.
%
%
%% Syntax
%   pf = loadPoleFigure(fname)
%
%   fnames = {fname1,...,fnameN}  % define filename(s)
%   h = {h1,..,hN}                % define crystal directions
%   c = {c1,..,cN}                % define structure coefficients
%   pf = loadPoleFigure(fnames,h,cs,ss,'superposition',c)
%
%% Input
%  fname     - filename(s)
%  h1,...,hN - @Miller crystal directions (optional)
%  c1,...,cN - structure coefficients for superposed pole figures (optional)
%  cs, ss    - crystal, specimen @symmetry (optional)
%
%% Options
%  interface  - specific interface to be used
%  comment    - comment to be associated with the data
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% ImportPoleFigureData PoleFigure/calcODF examples_index


[pf,interface,options,ipf] = loadData(fname,'PoleFigure',varargin{:});
