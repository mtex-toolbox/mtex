/*=========================================================================
* SHTextractormex.c - extract harmonic coefficients and symmetry properties
* from SHT-files.
*
* Syntax
*  [coeff,sym] = SHTextractormex(file);
*
* Input
*  file - file path/name
*
* Output
*  coeff - harmonic coefficients
*  sym   - struct of symmetry properties 
*
* This is a MEX-file for MATLAB.
*
*=======================================================================*/

#include <mex.h>
#include <math.h>
#include <matrix.h>
#include <complex.h>
#include <string.h>

#include <cstdint>
#include <filesystem>
#include <iostream>
#include <fstream>
#include <algorithm>

#include "sht_file.hpp"

// The gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

  mxComplexDouble *outFourierCoeff; // output fourier coefficient matrix
  char* file;

  // check for 1 input arguments (inCoeff & bandwith)
  if(nrhs<1)
    mexErrMsgIdAndTxt("SHTextractormex:invalidNumInputs","One input required.");

  // check for 1 or 2 output argument (outFourierCoeff and maybe symmetry)
  if( (nlhs!=1) && (nlhs!=2) )
    mexErrMsgIdAndTxt("SHTextractormex:maxlhs","One output required.");


  // read input data (get the file path)
  file = mxArrayToString(prhs[0]);

  // open SHT-File
  sht::File shtfile;
  std::ifstream is(file, std::ios::in | std::ios::binary);
  shtfile.read(is);

  // get bandwidth from SHT-File
  std::uint64_t bw = (std::uint64_t)shtfile.harmonics.bw();

  // get vector of SH-coefficients from SHT-File
  std::vector<std::complex<std::double_t>> harmonics(bw*bw, std::complex<double>(0.0, 1.0));
  // write SH-coefficients into a vector
  sht::HarmonicsData::UnpackHarm(shtfile.harmonics.alm.data(), harmonics.data() , bw, shtfile.harmonics.zRot(), shtfile.harmonics.cmpFlg());

  // create output data of coefficients
  mwSize NumCoeff;
  NumCoeff = bw*bw;
  plhs[0] = mxCreateNumericMatrix(1, NumCoeff, mxDOUBLE_CLASS, mxCOMPLEX);

  // create a pointer to the data in the output array (outFourierCoeff)
  outFourierCoeff = mxGetComplexDoubles(plhs[0]);

  // convert data formats to mex
  int k;
  for (k=0; k<NumCoeff; k++)
  {
    outFourierCoeff[k].real = harmonics[k].real();
    outFourierCoeff[k].imag = harmonics[k].imag();
  }


  // Crystal Data
  if (nlhs==2){
    // Pointer to CrystalData objekt of data type CrystalData
    sht::CrystalData& xtal = shtfile.mpData.xtals.back();
    // Get material as string from CrystalData
    std::string str = xtal.name;
    // transform to char variable
    const char *cstr = str.c_str();
    // get spaceId from CrystalData
    mwSize dims[2] = {1, 1};
    mxArray* spaceId;
    spaceId = mxCreateDoubleMatrix(1, 1, mxREAL);
    *mxGetDoubles(spaceId) = xtal.sgNum();
    // get lattice parameters {a,b,c,alpha,beta,gamma}
    mxArray* lattice;
    lattice = mxCreateDoubleMatrix(1, 6, mxREAL);
    for (int i = 0; i < 6; i++) {
      mxGetDoubles(lattice)[i] = xtal.lat()[i];
    }
    // Construct Data struct and insert the properties
    const char* field_names[] = {"Mineral", "SpaceId","LatticeParameters"};
    plhs[1] = mxCreateStructArray(1, dims, 3, field_names);
    mxSetFieldByNumber(plhs[1], 0, 0, mxCreateString(cstr));
    mxSetFieldByNumber(plhs[1], 0, 1, spaceId);
    mxSetFieldByNumber(plhs[1], 0, 2, lattice);
  }

  // close the SHT-File
  is.close();

  // free the storage
  mxFree(file);

}

