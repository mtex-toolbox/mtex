function rgb = spectralTransmission(nMin,nMax,p,thickness,varargin)
% Syntax
%
%
% Input
%  nMin,nMax - birefringence
%  p - direction of the polarizer
%  thikness - 
%  tau - angle between polarizer and analyzer
%

rgb = csvread('ciexyz31_1.csv')';%CIE_1931_XYZ to RGB 65 whitepoint
%X_Y_Z_convert = csvread('sbrgb10w.csv',0 ,1)';%Stiles & Burch

% first column is wavelength
lambda = 1./rgb(:,1);

% second to fourth line are RGB values - |lambda| x 3
rgb(:,1) = [];

% 
phi = angle(p,nMin);

% angle between polarizer and analyzer
tau = get_option(varargin,'tau',45*degree);

% path difference between fast and slow waves
delta = (nMax - nMin) .* thickness;

% compute spectra - |nMin| x |lambda|
Ls = cos(phi).^2 - sin(2*(tau -phi(:))) * sin(2*tau) * sin(delta(:) * lambda).^2;

% spectra to color -> |nMin| x 3
L_XYZ = Ls * rgb;

%Adobe RGB
AdobeRGB = [2.04414 -0.5649 -0.3447;...
  -0.9693 1.8760 0.0416;...
  0.0134 -0.1184 1.0154];

%L_RGB_initial = [3.240479 -1.537150 -0.498535; -0.969256 1.875992 0.041556; 0.055648 -0.204043 1.057311]*L_XYZ;%SRGB
%L_RGB =[2.6423 -1.2234 -0.3930; -1.1120 2.0590 0.0160; 0.0822 -0.2807 1.4560]*L_XYZ;%colormatch RGB
%L_RGB_initial = 0.17697*[ 3.240479 -1.537150 -0.498535 ; -0.969256  1.875992  0.041556;  0.055648 -0.204043  1.057311 ]*L_XYZ;%function from the internett

rgb = rgb * AdobeRGB.';

end