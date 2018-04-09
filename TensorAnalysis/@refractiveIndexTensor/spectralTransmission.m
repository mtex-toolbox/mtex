function rgb = spectralTransmission(rI,vprop,thickness,varargin)
%
% Syntax
%   rgb = spectralTransmission(rI,vprop,p,thickness)
%
%   rgb = spectralTransmission(rI,vprop,p,thickness,'polarizationDirection',p)
%
%   rgb = spectralTransmission(rI,vprop,p,thickness,'phi',phi)
%
%
% Input
%  rI - @refractiveIndexTensor
%  vprop - propagation direction
%  thickness - 
%  p - direction of the polarizer
%  tau - angle between polarizer and analyzer
%
% Example
%   thickness = 10000;
%   rI = refractiveIndexTensor.calcite
%   vprop = plotS2Grid;
%   rgb = spectralTransmission(rI,vprop,thickness);
%   plot3d(vprop,rgb./100)

% compute birefringence
[n,nMin,nMax] = rI.birefringence(vprop);

% for spectrum to rgb convertion
rgbMap = csvread(fullfile(mtex_path,'plotting','tools','ciexyz31_1.csv'));%CIE_1931_XYZ to RGB 65 whitepoint
%X_Y_Z_convert = csvread('sbrgb10w.csv',0 ,1)';%Stiles & Burch

% first column is wavelength
invLambda = 1./rgbMap(:,1).';

% second to fourth column are RGB values - |lambda| x 3
rgbMap(:,1) = [];

% extract polarization direction
if check_option(varargin,'polarizationDirection')
  polarizer = (get_option(varargin,'polarizationDirection'));
  tau = (angle(nMin,polarizer,'noSymmetry'));
  tau = repmat(tau(:),1,length(invLambda));
else
  tau = 45*degree;
end

% angle between polarizer and analyzer
phi = get_option(varargin,'phi',90*degree);

% path difference between fast and slow waves
delta = n .* thickness;

% compute spectra - |nMin| x |lambda|
spectra = cos(phi).^2 - sin(2*(tau -phi)) .* sin(2*tau) .* sin(delta(:).* invLambda*pi()).^2;
%Ls(i,:) = (cosd(phi(j)))^2 - sind(2*(tau -phi(j)))*sind(2*tau)*(sind((Delta./visible_spectrum(i))*180)).^2;
% spectra to color -> |nMin| x 3
rgb = spectra * rgbMap;

%Adobe RGB
AdobeRGB = [2.04414 -0.5649 -0.3447;...
  -0.9693 1.8760 0.0416;...
  0.0134 -0.1184 1.0154];

%L_RGB_initial = [3.240479 -1.537150 -0.498535; -0.969256 1.875992 0.041556; 0.055648 -0.204043 1.057311]*L_XYZ;%SRGB
%L_RGB =[2.6423 -1.2234 -0.3930; -1.1120 2.0590 0.0160; 0.0822 -0.2807 1.4560]*L_XYZ;%colormatch RGB
%L_RGB_initial = 0.17697*[ 3.240479 -1.537150 -0.498535 ; -0.969256  1.875992  0.041556;  0.055648 -0.204043  1.057311 ]*L_XYZ;%function from the internett

rgb = rgb * AdobeRGB.'/100;

end