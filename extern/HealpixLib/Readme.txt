HEALPix Library		Version 1.0

Yousuke NARUSE

1. Overview
This library provides some useful functions for using HEALPix pixelization 
implemented on MATLAB. The HEALPix is a pixelization scheme of a spherical 
surface having advantageous features as follows.
 - Each pixel covers the same surface area
 - The pixel centers occur on rings of constant latitude
 - Its pixel indexing scheme enables easier implementation of the Haar wavelet transform on spherical surfaces
 - It provides equal-area and iso-latitude map projection

Originally, a purpose of this sampling method is an efficient storage and 
processing of large sets of data for astronomical research. However, the 
method is also beneficial when we want to handle mathematical functions 
defined on spherical surface.

This library provides the following features.
 - Generation of the HEALPix sampling points on spherical surfaces
 - Implementation of the Haar transform in spherical sampling
 - Visualization of functions on sphere by means of the HEALPix projection
 - Visualization of pixel meshes of the HEALPix

2. Environment
Operation of this library had confirmed on the following environments.
 - MATLAB 7.1
 - MATLAB 2009a, 2009b
 - MATLAB 2010a, 2010b

3. Tutorials
This library consists of the following files. Usages of the top level 
functions are written as help comment in each file.

(A) Basic functions for pixelization

Given a resolution of the grid, "HealpixGenerateSampling.m" generates 
spherical coordinates or two-dimensional ring index of each sampling 
pixel. The pixels are ordered by so-called nested indexing.

[files]
HealpixGenerateSampling.m
HealpixNestedIndex.m
HealpixNestedIndexInv.m
HealpixGetSphCoord.m
HealpixNorthernHemisphere.m
SphToCart.m

(B) The HEALPix projection

This function calculates projection of 3D spherical surfaces onto 2D planes.
Given both a resolution of the HEALPix grid, and 2D plane,
"HealpixPlaneProjBmp.m" creates 2D bitmap of the specified resolution.
If a resolution of 2D plane was higher than the one of 3D surface, 
bitmap is rendered by means of linear interpolation.

[files]
HealpixPlaneProjBmp.m
HealpixPlanePoleDistort.m
HealpixPlanePoleDistortInv.m
HealpixProjectionOntoPlane.m
HealpixSelectPatchClass.m
HealpixGetPatchVertexCoordsB.m
HealpixGetPatchVertexCoordsE.m
HealpixGetPatchVertexCoordsO.m
HealpixGetPatchVertexCoordsP.m
HealpixGetPatchVertexCoordsR.m
HealpixGetPatchVertexCoordsT.m
HealpixGetPatchVertexWeightsRectangle.m
HealpixGetPatchVertexWeightsRhombus.m

(C) The Haar wavelets

"HealpixHaarTransform.m" and "HealpixInvHaarTransform.m" calculate the Haar 
transform and the inverse Haar transform under the HEALPix sampling, 
respectively.
Easy explanation about definition of the Haar transform on HEALPix is shown in the literature below.
Jason McEwen, "Data compression on the sphere with spherical Haar wavelets,"
Astronomical Data Analysis V, Crete, 2008.
http://www.mrao.cam.ac.uk/~jdm57/research/talks/szip_talk_ada5.pdf

[files]
HealpixHaarTransform.m
HealpixInvHaarTransform.m
HealpixNestedLinearTrans.m
HealpixNestedInvLinearTrans.m

(D) Demonstration of the HEALPix pixelization

"HealpixTest.m" plots sampling pixels of HEALPix.
A resolution of grid is configurable by editing the "n" value in the script.

[files]
HealpixTest.m

(E) Visualization of pixel meshes

"for_print.m" displays a mesh tessellation of HEALPix.
A resolution of grid is configurable by editing the "n" value in the script.

[files]
for_print.m
HealpixBorder.m
HealpixBorderGetNextEB.m
HealpixBorderGetNextPC.m
HealpixBorderLineEB.m
HealpixBorderLinePC.m

(D) Demonstration of the HEALPix projection

"ProjectionTest.m" displays HEALPix projection of a function defined in 
"DebugFunc.m." Its resolution parameters are specified by the variable 
n, n_x, and n_y in the script.

[files]
ProjectionTest.m
DebugFunc.m

(E) Demonstration of the Haar transform

"HaarTest.m" displays a histogram of coefficients of the Haar transform 
on HEALPix. In this example, transform target is defined by "DebugFunc.m." 
You can easily confirm sparsity of the signal when expressed in the 
wavelet basis, which is exploitable for many purposes such as data 
compression and compressed sensing.

[files]
HaarTest.m
DebugFunc.m

4. History
2011/02/05	Version 1.0	The first issue

5. Disclaimer
The author does not compensate any possible harms caused by this application.
Only those who have agreed this have the right to use this application.

6. Contact to author
Yousuke NARUSE
yous.naruse@nifty.com
http://homepage2.nifty.com/plasma/
