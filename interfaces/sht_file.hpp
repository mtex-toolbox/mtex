/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                                 *
 * Copyright (c) 2019, De Graef Group, Carnegie Mellon University                  *
 * All rights reserved.                                                            *
 *                                                                                 *
 * Author William C. Lenthe                                                        *
 *                                                                                 *
 * Redistribution and use in source and binary forms, with or without              *
 * modification, are permitted provided that the following conditions are met:     *
 *                                                                                 *
 * 1. Redistributions of source code must retain the above copyright notice, this  *
 *    list of conditions and the following disclaimer.                             *
 *                                                                                 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,    *
 *    this list of conditions and the following disclaimer in the documentation    *
 *    and/or other materials provided with the distribution.                       *
 *                                                                                 *
 * 3. Neither the name of the copyright holder nor the names of its                *
 *    contributors may be used to endorse or promote products derived from         *
 *    this software without specific prior written permission.                     *
 *                                                                                 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"     *
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       *
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE  *
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE    *
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL      *
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR      *
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER      *
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   *
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE   *
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.            *
 *                                                                                 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/**
 * This file is configured from the following template file:
 * @CMAKE_CURRENT_SOURCE_DIR@/sht_file.hpp.in
 * 
 * To fix compile errors in this file you need to edit the original file and NOT
 * this file.
 */


#ifndef _SHT_FILE_H_
#define _SHT_FILE_H_

#include <vector>
#include <iostream>
#include <memory>
#include <type_traits>
#include <complex>

namespace sht {

	static const char VersionString[9] = "XXX";

	static const int8_t VERSION_MAJOR = 1;
	static const int8_t VERSION_MINOR = 1;

	//@brief: all user defined types need methods to hash, sanity check, and read/write from a file
	struct CompoundData : std::vector<char> {

		//@brief: sanity check the contents of this data block (throw if not)
		virtual void sanityCheck() const {;}

		//@brief    : compute the CRC-32C hash of this data block
		//@param crc: initial hash value
		//@return   : new hash value
		virtual uint32_t computeHash(uint32_t crc) const;

		//@brief   : write data to an ostream
		//@param os: ostream to write to
		//@return  : os
		virtual std::ostream& write(std::ostream& os) const {return os.write(std::vector<char>::data(), std::vector<char>::size());}

		//@brief    : read data from an istream
		//@param is : istream to read from
		//@param swp: does the input stream need to be byte swapped (is the endedness mismatched)
		//@return   : is
		virtual std::istream& read(std::istream& is, const bool swp) {return is.read (std::vector<char>::data(), std::vector<char>::size());}

		//@brief: byte swap data
		virtual void byteSwap() = 0;

		//@brief  : access a block of data as a given type
		//@param n: offset to access at
		template <typename T> typename std::remove_pointer<T>::type const * nthByteAs(const size_t n, typename std::enable_if< std::is_pointer<T>::value >::type* = 0) const {return    T         (std::vector<char>::data() + n)     ; }
		template <typename T> typename std::remove_pointer<T>::type       * nthByteAs(const size_t n, typename std::enable_if< std::is_pointer<T>::value >::type* = 0)       {return    T         (std::vector<char>::data() + n)     ; }
		template <typename T>                                  T    const & nthByteAs(const size_t n, typename std::enable_if<!std::is_pointer<T>::value >::type* = 0) const {return ( (T const *)(std::vector<char>::data() + n) )[0]; }
		template <typename T>                                  T          & nthByteAs(const size_t n, typename std::enable_if<!std::is_pointer<T>::value >::type* = 0)       {return ( (T       *)(std::vector<char>::data() + n) )[0]; }

		//@brief  : expose size based constructor
		//@param n: length of data in bytes
		CompoundData(const size_t n = 0) : std::vector<char>(n, 0) {}
	};

	enum class Modality : int8_t {
		Unknown = 0x00,
		EBSD    = 0x01,//start of SEM techniques
		ECP     = 0x02,
		TKD     = 0x03,
		PED     = 0x11,//start of TEM techniques
		Laue    = 0x21,//start of X-Ray techniques
	};

	enum class Vendor : int8_t {
		Unknown = 0x00,
		EMsoft  = 0x01,
	};

	//@brief: abstract base class for vendor defined simulation data types
	struct SimulationData : public CompoundData {

		//@brief  : expose size based constructor
		//@param n: length of data in bytes
		SimulationData(const size_t n = 0) : CompoundData(n) {}

		//@brief: default destructor (for unique_ptr)
		virtual ~SimulationData() = default;

		//@brief  : check if this datatype supports a given modality
		//@param m: modality to check support for
		//@return : true if the data type supports m, false otherwise
		virtual bool forModality(const Modality& m) const = 0;

		//@brief : get the vendor this data type is associated with
		//@return: vendor
		virtual Vendor getVendor() const = 0;

		//@brief    : factory method to build known vendor specific simulation meta data types
		//@param mod: modality
		//@param ven: vendor
		//@return   : unique pointer allocated with vendor specific type (or NULL if known suitable type is known)
		static std::unique_ptr<SimulationData> Factory(const Modality mod, const Vendor ven);
	};

	//@file and target experiment info
	struct FileHeader : public CompoundData {
		std::string doi    ;//utf8 doi   storage (padded up to 8 byte multiple)
		std::string notes  ;//utf8 notes storage (padded up to 8 byte multiple)

		//@brief: constructor sets size and magic bytes
		FileHeader();

		//File and Version Identification

		//@brief : access magic bytes
		//@return: pointer to start of magic bytes (4x char)
		char const * magicBytes() const {return CompoundData::nthByteAs<char const*>(0);}
		char       * magicBytes()       {return CompoundData::nthByteAs<char      *>(0);}

		//@brief : access file version
		//@return: pointer to start of file version (2x int8_t, {major, minor})
		int8_t const * fileVersion() const {return CompoundData::nthByteAs<int8_t const*>(4);}
		int8_t       * fileVersion()       {return CompoundData::nthByteAs<int8_t      *>(4);}

		//@brief : access reserved bytes
		//@return: pointer to start of reserved bytes (2x int8_t)
		int8_t const * resBytes() const {return CompoundData::nthByteAs<int8_t const*>(6);}
		int8_t       * resBytes()       {return CompoundData::nthByteAs<int8_t      *>(6);}

		//@brief : access software version
		//@return: pointer to start of software version (8x char)
		char const * softwareVersion() const {return CompoundData::nthByteAs<char const*>(8);}
		char       * softwareVersion()       {return CompoundData::nthByteAs<char      *>(8);}

		// Experimental Conditions Spherical Function was Simulated for (modality dependent)

		//@brief : access diffraction modality
		//@return: modality type this file is intended for
		const Modality& modality() const {return CompoundData::nthByteAs<Modality>(16);}
		      Modality& modality()       {return CompoundData::nthByteAs<Modality>(16);}

		//@brief : access reserved bytes
		//@return: pointer to start of reserved bytes (3x int8_t)
		int8_t const * resBytes2() const {return CompoundData::nthByteAs<int8_t const*>(17);}
		int8_t       * resBytes2()       {return CompoundData::nthByteAs<int8_t      *>(17);}
		      
		//@brief : access beam energy
		//@return: beam energy in keV
		const float& beamEnergy() const {return CompoundData::nthByteAs<float>(20);}
		      float& beamEnergy()       {return CompoundData::nthByteAs<float>(20);}

		//@brief : access primary angle
		//@return: primary angle in degrees
		const float& primaryAngle() const {return CompoundData::nthByteAs<float>(24);}
		      float& primaryAngle()       {return CompoundData::nthByteAs<float>(24);}

		//@brief : access secondary angle
		//@return: secondary angle in degrees
		const float& secondaryAngle() const {return CompoundData::nthByteAs<float>(28);}
		      float& secondaryAngle()       {return CompoundData::nthByteAs<float>(28);}

		//@brief : access reserved experimenatal paramter
		//@return: reserved experimenatal paramter
		const float& reservedParam() const {return CompoundData::nthByteAs<float>(32);}
		      float& reservedParam()       {return CompoundData::nthByteAs<float>(32);}

		//Metadata

		//@brief : access doi string length
		//@return: doi string length in bytes
		const int16_t& doiLen() const {return CompoundData::nthByteAs<int16_t>(36);}
		      int16_t& doiLen()       {return CompoundData::nthByteAs<int16_t>(36);}

		//@brief : access note string length
		//@return: note string length in bytes
		const int16_t& noteLen() const {return CompoundData::nthByteAs<int16_t>(38);}
		      int16_t& noteLen()       {return CompoundData::nthByteAs<int16_t>(38);}

		//@brief: sanity check the contents of this data block (throw if not)
		void sanityCheck() const;

		//@brief    : compute the CRC-32C hash of this data block
		//@param crc: initial hash value
		//@return   : new hash value
		uint32_t computeHash(uint32_t crc) const;

		//@brief   : write data to an ostream
		//@param os: ostream to write to
		//@return  : os
		std::ostream& write(std::ostream& os) const;

		//@brief    : read data from an istream
		//@param is : istream to read from
		//@param swp: does the input stream need to be byte swapped (is the endedness mismatched)
		//@return   : is
		std::istream& read(std::istream& is, const bool swp);
		//@brief    : read data from an istream

		//@param is: istream to read from
		//@return  : is
		std::istream& read(std::istream& is) {return read(is, false);}//swp is a dummy parameter in this case since it is detected from the magic bytes

		//@brief: byte swap data
		void byteSwap();

		//@brief : check if the file is big/little endian using magic bytes
		//@return: true if big endian, false if little
		bool fileBig() const;

		//@brief : check if the the system is big/little endian
		//@return: true if big endian, false if little
		static bool SysBig();

		//@brief : check if the the system endedness is different from the file endedness
		//@return: true if mismatched, false if matching
		bool endianMismatch() const {return fileBig() != SysBig();}

		//@brief    : set the DOI string
		//@param str: new DOI string
		void setDoi(std::string str);

		//@brief    : set the notes string
		//@param str: new notes string
		void setNotes(std::string str);
	};

	//@brief: sub type for CrystalData
	struct AtomData : public CompoundData {
		//@brief: constructor sets size
		AtomData() : CompoundData(32) {}

		//@brief: default destructor (required to silence warnings virtual function warnings)
		virtual ~AtomData() = default;

		//@brief : access x position
		//@return: x position in 24ths of a
		const float& x() const {return CompoundData::nthByteAs<float>(0);}
		      float& x()       {return CompoundData::nthByteAs<float>(0);}

		//@brief : access y position
		//@return: y position in 24ths of b
		const float& y() const {return CompoundData::nthByteAs<float>(4);}
		      float& y()       {return CompoundData::nthByteAs<float>(4);}

		//@brief : access z position
		//@return: z position in 24ths of c
		const float& z() const {return CompoundData::nthByteAs<float>(8);}
		      float& z()       {return CompoundData::nthByteAs<float>(8);}

		//@brief : access occupancy
		//@return: occupancy [0,1]
		const float& occ() const {return CompoundData::nthByteAs<float>(12);}
		      float& occ()       {return CompoundData::nthByteAs<float>(12);}

		//@brief : access charge
		//@return: charge in atomic units
		const float& charge() const {return CompoundData::nthByteAs<float>(16);}
		      float& charge()       {return CompoundData::nthByteAs<float>(16);}

		//@brief : access Debye-Waller factor
		//@return: Debye-Waller factor in nm^2
		const float& debWal() const {return CompoundData::nthByteAs<float>(20);}
		      float& debWal()       {return CompoundData::nthByteAs<float>(20);}

		//@brief : access reserved float parameter
		//@return: reserved float paramete
		const float& resFp() const {return CompoundData::nthByteAs<float>(24);}
		      float& resFp()       {return CompoundData::nthByteAs<float>(24);}

		//@brief : access atomic number
		//@return: atomic number
		const int8_t& atZ() const {return CompoundData::nthByteAs<int8_t>(28);}
		      int8_t& atZ()       {return CompoundData::nthByteAs<int8_t>(28);}

		//@brief : access reserved bytes
		//@return: pointer to start of reserved bytes (3x int8_t)
		int8_t const * resBytes() const {return CompoundData::nthByteAs<int8_t const*>(29);}
		int8_t       * resBytes()       {return CompoundData::nthByteAs<int8_t      *>(29);}

		//@brief: sanity check the contents of this data block (throw if not)
		void sanityCheck() const;

		//@brief: byte swap data
		void byteSwap();
	};

	//@brief: crystal structure definition
	struct CrystalData : public CompoundData {
		//Space Group Axis Choice Enumeration
		enum class Axis : int8_t {
			Orth_ABC = 0x01, Mono_B  = 0x01, Default = 0x01,
			Orth_BAC = 0x02, Mono_nB = 0x02,
			Orth_CAB = 0x03, Mono_C  = 0x03,
			Orth_CBA = 0x04, Mono_nC = 0x04,
			Orth_BCA = 0x05, Mono_A  = 0x05,
			Orth_ACB = 0x06, Mono_nA = 0x06,
		};

		//Space Group Cell Choice Enumeration
		enum class Cell : int8_t {
			Mono_1 = 0x01, Trig_Hex = 0x01, Default   = 0x01,
			Mono_2 = 0x02,                  Tet_CF    = 0x02,
			Mono_3 = 0x03, Trig_Rhm = 0x03, TrigHex_H = 0x03,
		};

		std::vector<AtomData> atoms;//actual atoms
		std::string           form ;//formula
		std::string           name ;//phase/material name
		std::string           symb ;//structure symbol
		std::string           refs ;//reference(s), doi(s) preferred, bibtex key as fallback
		std::string           note ;//additional notes

		//@brief: constructor sets size
		CrystalData() : CompoundData(72) {}

		//@brief: default destructor (required to silence warnings virtual function warnings)
		virtual ~CrystalData() = default;

		//@brief : access space group number
		//@return: space group number
		const uint8_t& sgNum() const {return CompoundData::nthByteAs<uint8_t>(0);}
		      uint8_t& sgNum()       {return CompoundData::nthByteAs<uint8_t>(0);}

		//@brief : access international tables origin choice
		//@return: international tables origin choice
		const int8_t& sgSet() const {return CompoundData::nthByteAs<int8_t>(1);}
		      int8_t& sgSet()       {return CompoundData::nthByteAs<int8_t>(1);}

		//@brief : access space group axis choice
		//@return: space group axis choice
		const Axis& sgAxis() const {return CompoundData::nthByteAs<Axis>(2);}
		      Axis& sgAxis()       {return CompoundData::nthByteAs<Axis>(2);}

		//@brief : access space group cell choice
		//@return: space group cell choice
		const Cell& sgCell() const {return CompoundData::nthByteAs<Cell>(3);}
		      Cell& sgCell()       {return CompoundData::nthByteAs<Cell>(3);}

		//@brief : access x origin shift relative to intl. tables origin
		//@return: x origin shift in 24ths of a
		const float& oriX() const {return CompoundData::nthByteAs<float>(4);}
		      float& oriX()       {return CompoundData::nthByteAs<float>(4);}

		//@brief : access y origin shift relative to intl. tables origin
		//@return: y origin shift in 24ths of b
		const float& oriY() const {return CompoundData::nthByteAs<float>(8);}
		      float& oriY()       {return CompoundData::nthByteAs<float>(8);}

		//@brief : access z origin shift relative to intl. tables origin
		//@return: z origin shift in 24ths of c
		const float& oriZ() const {return CompoundData::nthByteAs<float>(12);}
		      float& oriZ()       {return CompoundData::nthByteAs<float>(12);}

		//@brief : lattice parameters in nm/degrees
		//@return: lattice parameters {a, b, c, alpha, beta, gamma}
		float const * lat() const {return CompoundData::nthByteAs<float const*>(16);}
		float       * lat()       {return CompoundData::nthByteAs<float      *>(16);}

		//@brief : rotation applied to spherical signal {sense from material data}
		//@return: rotation as {w,x,y,z} quaternion {pijk from material data}
		float const * rot() const {return CompoundData::nthByteAs<float const*>(40);}
		float       * rot()       {return CompoundData::nthByteAs<float      *>(40);}

		//@brief : access weighting for signal averaging
		//@return: weighting for signal averaging
		const float& weight() const {return CompoundData::nthByteAs<float>(56);}
		      float& weight()       {return CompoundData::nthByteAs<float>(56);}

		//@brief : access number of atoms
		//@return: number of atoms
		const int16_t& numAtoms() const {return CompoundData::nthByteAs<int16_t>(60);}
		      int16_t& numAtoms()       {return CompoundData::nthByteAs<int16_t>(60);}

		//@brief : access formula string length
		//@return: formula string length in bytes
		const int16_t& formulaLen() const {return CompoundData::nthByteAs<int16_t>(62);}
		      int16_t& formulaLen()       {return CompoundData::nthByteAs<int16_t>(62);}

		//@brief : access maerial/phase name string length
		//@return: maerial/phase name string length in bytes
		const int16_t& matNameLen() const {return CompoundData::nthByteAs<int16_t>(64);}
		      int16_t& matNameLen()       {return CompoundData::nthByteAs<int16_t>(64);}

		//@brief : access structure symbol string length
		//@return: structure symbol string length in bytes
		const int16_t& structSymLen() const {return CompoundData::nthByteAs<int16_t>(66);}
		      int16_t& structSymLen()       {return CompoundData::nthByteAs<int16_t>(66);}

		//@brief : access structure symbol string length
		//@return: structure symbol string length in bytes
		const int16_t& refsLen() const {return CompoundData::nthByteAs<int16_t>(68);}
		      int16_t& refsLen()       {return CompoundData::nthByteAs<int16_t>(68);}
		      
		//@brief : access structure symbol string length
		//@return: structure symbol string length in bytes
		const int16_t& noteLen() const {return CompoundData::nthByteAs<int16_t>(70);}
		      int16_t& noteLen()       {return CompoundData::nthByteAs<int16_t>(70);}

		//@brief: sanity check the contents of this data block (throw if not)
		void sanityCheck() const;

		//@brief    : compute the CRC-32C hash of this data block
		//@param crc: initial hash value
		//@return   : new hash value
		uint32_t computeHash(uint32_t crc) const;

		//@brief   : write data to an ostream
		//@param os: ostream to write to
		//@return  : os
		std::ostream& write(std::ostream& os) const;

		//@brief    : read data from an istream
		//@param is : istream to read from
		//@param swp: does the input stream need to be byte swapped (is the endedness mismatched)
		//@return   : is
		std::istream& read(std::istream& is, const bool swp);

		//@brief: byte swap data
		void byteSwap();

		//@brief    : set the formula string
		//@param str: new formula string
		void setFormula(std::string str);

		//@brief    : set the material/phase name string
		//@param str: new material/phase name string
		void setName(std::string str);

		//@brief    : set the structure symbol string
		//@param str: new structure symbol string
		void setStructSym(std::string str);

		//@brief    : set the references string
		//@param str: new references string
		void setRefs(std::string str);
		
		//@brief    : set the note string
		//@param str: new note string
		void setNote(std::string str);
	};

	//@brief: crystal structure definition
	struct MasterPatternData : public CompoundData {
	
		std::vector< CrystalData                     > xtals;//actual crystal definitions
		std::vector< std::unique_ptr<SimulationData> > simul;//simulation meta data

		//@brief: constructor sets size
		MasterPatternData() : CompoundData(8) {}

		//@brief : access number of crystals averaged
		//@return: number of crystals averaged
		const int8_t& numXtal() const {return CompoundData::nthByteAs<int8_t>(0);}
		      int8_t& numXtal()       {return CompoundData::nthByteAs<int8_t>(0);}

		//@brief : access effective space group number
		//@return: effective space group number
		const uint8_t& sgEff() const {return CompoundData::nthByteAs<uint8_t>(1);}
		      uint8_t& sgEff()       {return CompoundData::nthByteAs<uint8_t>(1);}

		//@brief : access quaternion pijk (+/-1) for crystal rotations
		//@return: \hat{i} * \hat{j}
		const int8_t& pijk() const {return CompoundData::nthByteAs<int8_t>(2);}
		      int8_t& pijk()       {return CompoundData::nthByteAs<int8_t>(2);}

		//@brief : access rotation sense (active or passive)
		//@return: 97 (ascii 'a') for active, 112 (ascii 'p') for passive
		const int8_t& rotSense() const {return CompoundData::nthByteAs<int8_t>(3);}
		      int8_t& rotSense()       {return CompoundData::nthByteAs<int8_t>(3);}

		//@brief : access simulated modality
		//@return: modality type
		const Modality& modality() const {return CompoundData::nthByteAs<Modality>(4);}
		      Modality& modality()       {return CompoundData::nthByteAs<Modality>(4);}

		//@brief : access simulation vendor
		//@return: vendor type
		const Vendor& vendor() const {return CompoundData::nthByteAs<Vendor>(5);}
		      Vendor& vendor()       {return CompoundData::nthByteAs<Vendor>(5);}

		//@brief : access size of simulation meta data
		//@return: size of simulation meta data (single entry, total size is simMetaSize() * numXtal
		const int16_t& simMetaSize() const {return CompoundData::nthByteAs<int16_t>(6);}
		      int16_t& simMetaSize()       {return CompoundData::nthByteAs<int16_t>(6);}

		//@brief: sanity check the contents of this data block (throw if not)
		void sanityCheck() const;

		//@brief    : compute the CRC-32C hash of this data block
		//@param crc: initial hash value
		//@return   : new hash value
		uint32_t computeHash(uint32_t crc) const;

		//@brief   : write data to an ostream
		//@param os: ostream to write to
		//@return  : os
		std::ostream& write(std::ostream& os) const;

		//@brief    : read data from an istream
		//@param is : istream to read from
		//@param swp: does the input stream need to be byte swapped (is the endedness mismatched)
		//@return   : is
		std::istream& read(std::istream& is, const bool swp);

		//@brief: byte swap data
		void byteSwap();
	};

	//@brief: actual spherical harmonics storage
	struct HarmonicsData : public CompoundData {
	
		std::vector<double> alm;//actual harmonics

		//@brief: constructor sets size
		HarmonicsData() : CompoundData(8) {}

		//@brief : access bandwidth
		//@return: bandwidth
		const int16_t& bw() const {return CompoundData::nthByteAs<int16_t>(0);}
		      int16_t& bw()       {return CompoundData::nthByteAs<int16_t>(0);}

		//@brief : access z rotational order used for compression
		//@return: z rotational order used for compression
		const int8_t& zRot() const {return CompoundData::nthByteAs<int8_t>(2);}
		      int8_t& zRot()       {return CompoundData::nthByteAs<int8_t>(2);}

		//@brief : access compression flags
		//@return: mirror / inversion symmetry compression flags
		//@note  : flags are 4 element bitmask
		//         0x01 - set if there is inversion symmetry
		//         0x02 - set if there is a mirror plane at the equator
		//         0x04 - set if there is a mirror plane with +y normal (normal to equator through phi = 0)
		//         0x08 - set if there is a mirror plane normal to equator through phi = 90 / zRot() e.g. m11, -42m, or, 3m1
		const int8_t& cmpFlg() const {return CompoundData::nthByteAs<int8_t>(3);}
		      int8_t& cmpFlg()       {return CompoundData::nthByteAs<int8_t>(3);}

		//@brief : access number of stored doubles
		//@return: number of stored doubles
		const int32_t& doubCnt() const {return CompoundData::nthByteAs<int32_t>(4);}
		      int32_t& doubCnt()       {return CompoundData::nthByteAs<int32_t>(4);}

		//@brief: sanity check the contents of this data block (throw if not)
		void sanityCheck() const;

		//@brief    : compute the CRC-32C hash of this data block
		//@param crc: initial hash value
		//@return   : new hash value
		uint32_t computeHash(uint32_t crc) const;

		//@brief   : write data to an ostream
		//@param os: ostream to write to
		//@return  : os
		std::ostream& write(std::ostream& os) const;

		//@brief    : read data from an istream
		//@param is : istream to read from
		//@param swp: does the input stream need to be byte swapped (is the endedness mismatched)
		//@return   : is
		std::istream& read(std::istream& is, const bool swp);

		//@brief: byte swap data
		void byteSwap();

		//@brief  : compute the number of non-zero spherical harmonic transform coefficients
		//@param b: bandwidth to compute for
		//@param n: z rotational order
		//@param f: compression flag
		//@return : the number of harmonic coefficients (# doubles)
		static uint32_t NumHarm(const int16_t b, const int8_t n, const int8_t f);

		//@brief    : compress spherical harmonics
		//@param in : harmonics to compress with m, l at in[m * bw + l]
		//@param out: location to write compressed coefficients
		//@param b  : bandwidth
		//@param n  : z rotational order
		//@param f  : compression flag
		template <typename Real>
		static void PackHarm(std::complex<Real> const * in, Real * out, const int16_t b, const int8_t n, const int8_t f);
		template <typename Real>
		       void packHarm(std::complex<Real> const * in, Real * out) {return PackHarm(in, out, bw(), zRot(), cmpFlg());}

		//@brief    : decompress spherical harmonics
		//@param in : compressed coefficients to unpack
		//@param out: location to write uncompressed harmoincs harmonics with m, l at out[m * bw + l]
		//@param b  : bandwidth
		//@param n  : z rotational order
		//@param f  : compression flag
		template <typename Real>
		static void UnpackHarm(Real const * in, std::complex<Real> * out, const int16_t b, const int8_t n, const int8_t f);
		template <typename Real>
		       void unpackHarm(Real const * in, std::complex<Real> * out) {return UnpackHarm(in, out, bw(), zRot(), cmpFlg());}

		//@brief   : get the z rotational order for a given space group
		//@param sg: space group number
		//@return  : z rotational order
		//@note    : assumes standard settings (monoclinic unique axis b, orthorhombic axis choice abc)
		static int8_t SpaceGroupRot(const uint8_t sg);

		//@brief   : get the compression flags for a given space group
		//@param sg: space group number
		//@return  : compression bitmask
		//@note    : assumes standard settings (monoclinic unique axis b, orthorhombic axis choice abc)
		static int8_t SpaceGroupCmp(const uint8_t sg);

	};

	//@brief: harmonics master pattern binary file v1.0
	struct File {
		FileHeader                      header   ;
		MasterPatternData               mpData   ;
		HarmonicsData                   harmonics;
		uint32_t                        crcHash  ;

		//@brief: sanity check the contents of this data block (throw if not)
		void sanityCheck() const;

		//@brief    : compute the CRC-32C hash of this data block
		//@param crc: initial hash value
		//@return   : new hash value
		uint32_t computeHash(uint32_t crc) const;

		//@brief   : write data to an ostream
		//@param os: ostream to write to
		//@return  : os
		std::ostream& write(std::ostream& os) const;

		//@brief   : read data from an istream
		//@param is: istream to read from
		//@return  : is
		std::istream& read (std::istream& is);

		//@brief     : create an file without any master pattern data from EMsoft style data
		//@param iprm: integer parameters {sgn, mod, bw}
		//             sgn - effective space group number of spherical function
		//             mod - modality (see enumeration, EBSD == 1)
		//             bw  - bandwidth
		//@param fprm: float {keV, sig, tht, res} e.g. {20.0, 70.0, 0.0, 0.0} for typical EBSD
		//             keV - beam energy in keV
		//             sig - primary tilt angle
		//             tht - secondary tilt angle
		//             res - reserved parameter
		//@param doi : file DOI string (null terminated)
		//@param note: file level notes (null terminated)
		//@param alm : actual harmonics (uncompressed format)
		//@return    : error code (void return function throws instead)
		void initFileEMsoft   (int32_t const * iprm, float const * fprm, char const * doi, char const * note, double const * alm);
		int  initFileEMsoftRet(int32_t const * iprm, float const * fprm, char const * doi, char const * note, double const * alm);

		//@brief     : add master pattern data to a file
		//@param iprm: integer paramters {sgn, sgs, nat, nel, elm, nsx, npx, grd}
		//       crystal data
		//             sgn - space group number
		//             sgs - space group setting
		//             nat - number of atoms
		//       simulation data
		//             nel - number of electrons
		//             elm - electron multiplier
		//             nsx - numsx (monte carlo grid size)
		//             npx - npx (master pattern grid size)
		//             grd - lattitude grid type
		//@param fprm: floating point parameters {a, b, c, alp, bet, gam, sgs, sge, sst, omg, kev, emn, esz, dmx, dmn, thk, c1, c2, c3, ddd, dmi}
		//       crystal data
		//             a   - lattice constant a in nm
		//             b   - lattice constant b in nm
		//             c   - lattice constant c in nm
		//             alp - lattice constant alpha in degrees
		//             bet - lattice constant beta  in degrees
		//             gam - lattice constant gamma in degrees
		//       simulation data
		//             sgs - sigma start
		//             sge - sigma end
		//             sst - sigma step
		//             omg - omega
		//             kev - keV
		//             emn - eHistMin
		//             esz - eBinSize
		//             dmx - depthMax
		//             dmn - depthMin
		//             thk - thickness
		//             c1  - c1
		//             c2  - c2
		//             c3  - c3
		//             ddd - sigDbDiff
		//             dmi - dMin
		//@param aTy : atom types (nAt atomic numbers)
		//@param aCd : atom coordinates (nAt * 5 floats {x, y, z, occupancy, Debye-Waller in nm^2})
		//@param vers: EMsoft version string (8 characters, null termination not required)
		//@param cprm: string parameters as one concatenated sequence will null seperators (+ final null terminator)
		//             {frm, nam, syb, ref}
		//             frm - formula string (null terimated)
		//             nam - material phase/name string (null terminated)
		//             syb - structure symbol string (null terminated)
		//             ref - reference string (null terminated)
		//             nte - note string (null terminated)
		//@return    : error code (void return function throws instead)
		void addDataEMsoft   (int32_t const * iprm, float const * fprm, int32_t const * aTy, float const * aCd, char const * vers, char const * cprm);
		int  addDataEMsoftRet(int32_t const * iprm, float const * fprm, int32_t const * aTy, float const * aCd, char const * vers, char const * cprm);
	};

}

////////////////////////////////////////////////////////////////////////////////
//                            SimulationData Types                            //
////////////////////////////////////////////////////////////////////////////////

namespace sht {

	//@brief: class to encapsulate simulation data from an EMsoft electron diffraction simulation
	struct EMsoftED : public SimulationData {

		//@brief: constructor sets size
		EMsoftED() : SimulationData(88) {}

		//@brief : access emsoft version
		//@return: pointer to start of emsoft version (8x char)
		char const * emsoftVersion() const {return CompoundData::nthByteAs<char const*>(0);}
		char       * emsoftVersion()       {return CompoundData::nthByteAs<char      *>(0);}

		//@return: start angle in degrees (or sig for full mode)
		const float& sigStart() const {return CompoundData::nthByteAs<float>(8);}
		      float& sigStart()       {return CompoundData::nthByteAs<float>(8);}

		//@return: end angle in degrees (or NAN for full mode)
		const float& sigEnd() const {return CompoundData::nthByteAs<float>(12);}
		      float& sigEnd()       {return CompoundData::nthByteAs<float>(12);}

		//@return: angle step size in degrees (or NAN for full mode)
		const float& sigStep() const {return CompoundData::nthByteAs<float>(16);}
		      float& sigStep()       {return CompoundData::nthByteAs<float>(16);}

		//@return: secondary tilt angle in degrees
		const float& omega() const {return CompoundData::nthByteAs<float>(20);}
		      float& omega()       {return CompoundData::nthByteAs<float>(20);}

		//@return: incident beam energy in keV
		const float& keV() const {return CompoundData::nthByteAs<float>(24);}
		      float& keV()       {return CompoundData::nthByteAs<float>(24);}

		//@return: minimum energy to consider in keV 
		const float& eHistMin() const {return CompoundData::nthByteAs<float>(28);}
		      float& eHistMin()       {return CompoundData::nthByteAs<float>(28);}

		//@return: energy bin size in keV
		const float& eBinSize() const {return CompoundData::nthByteAs<float>(32);}
		      float& eBinSize()       {return CompoundData::nthByteAs<float>(32);}

		//@return: maximum depth to consider for statistics in nm
		const float& depthMax() const {return CompoundData::nthByteAs<float>(36);}
		      float& depthMax()       {return CompoundData::nthByteAs<float>(36);}

		//@return: depth step size in nm
		const float& depthStep() const {return CompoundData::nthByteAs<float>(40);}
		      float& depthStep()       {return CompoundData::nthByteAs<float>(40);}

		//@return: foil thickness in nm (INF for non-foil)
		const float& thickness() const {return CompoundData::nthByteAs<float>(44);}
		      float& thickness()       {return CompoundData::nthByteAs<float>(44);}

		//@return: number of electrons
		const int64_t& totNumEl() const {return CompoundData::nthByteAs<int64_t>(48);}
		      int64_t& totNumEl()       {return CompoundData::nthByteAs<int64_t>(48);}

		//@return: monte carlo grid size in pixels
		const int16_t& numSx() const {return CompoundData::nthByteAs<int16_t>(56);}
		      int16_t& numSx()       {return CompoundData::nthByteAs<int16_t>(56);}

		//@return: pointer to start of reserved bytes (2x int8_t)
		int8_t const * resBytes1() const {return CompoundData::nthByteAs<int8_t const*>(58);}
		int8_t       * resBytes1()       {return CompoundData::nthByteAs<int8_t      *>(58);}

		//@return: strong beam cutoff
		const float& c1() const {return CompoundData::nthByteAs<float>(60);}
		      float& c1()       {return CompoundData::nthByteAs<float>(60);}

		//@return: weak beam cutoff
		const float& c2() const {return CompoundData::nthByteAs<float>(64);}
		      float& c2()       {return CompoundData::nthByteAs<float>(64);}

		//@return: complete cutoff
		const float& c3() const {return CompoundData::nthByteAs<float>(68);}
		      float& c3()       {return CompoundData::nthByteAs<float>(68);}

		//@return: double diffraction max excitation error in nm^-1
		const float& sigDbDiff() const {return CompoundData::nthByteAs<float>(72);}
		      float& sigDbDiff()       {return CompoundData::nthByteAs<float>(72);}

		//@return: minimum d spacing to consider in nm
		const float& dMin() const {return CompoundData::nthByteAs<float>(76);}
		      float& dMin()       {return CompoundData::nthByteAs<float>(76);}

		//@return: EBSD grid half size in pixels
		const int16_t& numPx() const {return CompoundData::nthByteAs<int16_t>(80);}
		      int16_t& numPx()       {return CompoundData::nthByteAs<int16_t>(80);}

		//@return: grid flag (1/2 for square lambert/legendre)
		const int8_t& latGridType() const {return CompoundData::nthByteAs<int8_t>(82);}
		      int8_t& latGridType()       {return CompoundData::nthByteAs<int8_t>(82);}

		//@return: pointer to start of reserved bytes (5x int8_t)
		int8_t const * resBytes2() const {return CompoundData::nthByteAs<int8_t const*>(83);}
		int8_t       * resBytes2()       {return CompoundData::nthByteAs<int8_t      *>(83);}

		//@brief  : check if this datatype supports a given modality
		//@param m: modality to check support for
		//@return : true if the data type supports m, false otherwise
		bool forModality(const Modality& m) const;

		//@brief : get the vendor this data type is associated with
		//@return: vendor
		Vendor getVendor() const {return Vendor::EMsoft;}

		//@brief: byte swap data
		void byteSwap();

		//@brief: sanity check the contents of this data block (throw if not)
		void sanityCheck() const;
	};

	//@brief: class to encapsulate simulation data from an EMsoft x-ray diffraction simulation
	struct EMsoftXD : public SimulationData {

		//@brief: constructor sets size
		EMsoftXD() : SimulationData(32) {}

		//@brief : access emsoft version
		//@return: pointer to start of emsoft version (8x char)
		char const * emsoftVersion() const {return CompoundData::nthByteAs<char const*>(0);}
		char       * emsoftVersion()       {return CompoundData::nthByteAs<char      *>(0);}

		//@return: minimum wave length in nm
		const float& lambdaMin() const {return CompoundData::nthByteAs<float>(8);}
		      float& lambdaMin()       {return CompoundData::nthByteAs<float>(8);}

		//@return: maximnum wave length in nm
		const float& lambdaMax() const {return CompoundData::nthByteAs<float>(12);}
		      float& lambdaMax()       {return CompoundData::nthByteAs<float>(12);}

		//@return: von Mises-Fisher distribution concentration
		const float& kappaVMF() const {return CompoundData::nthByteAs<float>(16);}
		      float& kappaVMF()       {return CompoundData::nthByteAs<float>(16);}

		//@return: intensity truncation factor
		const float& intFactor() const {return CompoundData::nthByteAs<float>(20);}
		      float& intFactor()       {return CompoundData::nthByteAs<float>(20);}

		//@return: grid half size in pixels
		const int16_t& numPx() const {return CompoundData::nthByteAs<int16_t>(24);}
		      int16_t& numPx()       {return CompoundData::nthByteAs<int16_t>(24);}

		//@return: sampling patch size
		const int8_t& patchW() const {return CompoundData::nthByteAs<int8_t>(26);}
		      int8_t& patchW()       {return CompoundData::nthByteAs<int8_t>(26);}

		//@return: pointer to start of reserved bytes (5x int8_t)
		int8_t const * resBytes() const {return CompoundData::nthByteAs<int8_t const*>(27);}
		int8_t       * resBytes()       {return CompoundData::nthByteAs<int8_t      *>(27);}

		//@brief  : check if this datatype supports a given modality
		//@param m: modality to check support for
		//@return : true if the data type supports m, false otherwise
		bool forModality(const Modality& m) const;

		//@brief : get the vendor this data type is associated with
		//@return: vendor
		Vendor getVendor() const {return Vendor::EMsoft;}

		//@brief: byte swap data
		void byteSwap();

		//@brief: sanity check the contents of this data block (throw if not)
		void sanityCheck() const;
	};

}

////////////////////////////////////////////////////////////////////////////////
//                              Implementations                               //
////////////////////////////////////////////////////////////////////////////////

#include <limits>
#include <cmath>
#include <fstream>

static_assert(sizeof(char) == sizeof(int8_t)        , "char must be 8 bits"    );
static_assert(std::numeric_limits<float >::is_iec559, "float  must be IEEE 754");
static_assert(std::numeric_limits<double>::is_iec559, "double must be IEEE 754");

namespace sht {

	namespace detail {
		uint16_t byteSwap(const uint16_t& v) {return                        ((v<< 8)&  0xFF00  ) | ((v>> 8)&  0x00FF  )                       ;}
		uint32_t byteSwap(const uint32_t& v) {return ((v<<24)&0xFF000000) | ((v<< 8)&0x00FF0000) | ((v>> 8)&0x0000FF00) | ((v>>24)&0x000000FF);}
		uint64_t byteSwap(const uint64_t& v) {
			return ((v<<56)&0xFF00000000000000) ||
			       ((v<<40)&0x00FF000000000000) ||
			       ((v<<24)&0x0000FF0000000000) ||
			       ((v<< 8)&0x000000FF00000000) ||
			       ((v<< 8)&0x00000000FF000000) ||
			       ((v<<24)&0x0000000000FF0000) ||
			       ((v<<40)&0x000000000000FF00) ||
			       ((v>>56)&0x00000000000000FF);
		}
		int16_t byteSwap(const int16_t& v) {return (int16_t)byteSwap((uint16_t)v);}
		int32_t byteSwap(const int32_t& v) {return (int32_t)byteSwap((uint32_t)v);}
		float   byteSwap(const float  & v) {return (float  )byteSwap((uint32_t)v);}
		double  byteSwap(const double & v) {return (double )byteSwap((uint64_t)v);}
		int64_t byteSwap(const int64_t& v) {return (int64_t)byteSwap((uint64_t)v);}

		//@brief      : compute the crc-32c checksum of data
		//@param data : data to compute checksum of
		//@param bytes: length of data in bytes
		//@param crc  : previous checksum value
		//@return     : new checksum value
		//@note       : this is relatively inefficient but nice and compact, if performance is a concern there are hardware accelerated versions
		uint32_t crc32c(unsigned char const * data, size_t bytes, uint32_t crc = 0x00000000) {
			/* on the fly table calculation
			static bool once = true;
			static uint32_t LUT[256];//lookup table for CRC calculation
			// static const uint32_t Poly = 0xedb88320;//reversed polynomial [normal   is 0x04C11DB7] (this is CRC-32  (what Gzip and PNG use))
			static const uint32_t Poly = 0x1edc6f41;//normal   polynomial [reversed is 0x1EDC6F41] (this is CRC-32C (what SSE4 instructions implement))
			if(once) {//the table hasn't been built yet
				once = false;//this isn't thread safe
				for(size_t i = 0; i < 256; i++) {//loop over table entries building
					LUT[i] = i;//seed with i
					for(size_t j = 0; j < 8; j++) {//do CRC calculation
						const bool xr = 0x00000001 == (LUT[i] & 0x00000001);
						LUT[i] >>= 1;
						if(xr) LUT[i] ^= Poly;
					}
				}
			}
			*/

			//precomputed LUT for normal CRC-32C (0x1edc6f41)
			static const uint32_t LUT[256] = {
				0x00000000, 0x0a5f4d75, 0x14be9aea, 0x1ee1d79f, 0x14c5eb57, 0x1e9aa622, 0x007b71bd, 0x0a243cc8,
				0x1433082d, 0x1e6c4558, 0x008d92c7, 0x0ad2dfb2, 0x00f6e37a, 0x0aa9ae0f, 0x14487990, 0x1e1734e5,
				0x15deced9, 0x1f8183ac, 0x01605433, 0x0b3f1946, 0x011b258e, 0x0b4468fb, 0x15a5bf64, 0x1ffaf211,
				0x01edc6f4, 0x0bb28b81, 0x15535c1e, 0x1f0c116b, 0x15282da3, 0x1f7760d6, 0x0196b749, 0x0bc9fa3c,
				0x16054331, 0x1c5a0e44, 0x02bbd9db, 0x08e494ae, 0x02c0a866, 0x089fe513, 0x167e328c, 0x1c217ff9,
				0x02364b1c, 0x08690669, 0x1688d1f6, 0x1cd79c83, 0x16f3a04b, 0x1caced3e, 0x024d3aa1, 0x081277d4,
				0x03db8de8, 0x0984c09d, 0x17651702, 0x1d3a5a77, 0x171e66bf, 0x1d412bca, 0x03a0fc55, 0x09ffb120,
				0x17e885c5, 0x1db7c8b0, 0x03561f2f, 0x0909525a, 0x032d6e92, 0x097223e7, 0x1793f478, 0x1dccb90d,
				0x11b258e1, 0x1bed1594, 0x050cc20b, 0x0f538f7e, 0x0577b3b6, 0x0f28fec3, 0x11c9295c, 0x1b966429,
				0x058150cc, 0x0fde1db9, 0x113fca26, 0x1b608753, 0x1144bb9b, 0x1b1bf6ee, 0x05fa2171, 0x0fa56c04,
				0x046c9638, 0x0e33db4d, 0x10d20cd2, 0x1a8d41a7, 0x10a97d6f, 0x1af6301a, 0x0417e785, 0x0e48aaf0,
				0x105f9e15, 0x1a00d360, 0x04e104ff, 0x0ebe498a, 0x049a7542, 0x0ec53837, 0x1024efa8, 0x1a7ba2dd,
				0x07b71bd0, 0x0de856a5, 0x1309813a, 0x1956cc4f, 0x1372f087, 0x192dbdf2, 0x07cc6a6d, 0x0d932718,
				0x138413fd, 0x19db5e88, 0x073a8917, 0x0d65c462, 0x0741f8aa, 0x0d1eb5df, 0x13ff6240, 0x19a02f35,
				0x1269d509, 0x1836987c, 0x06d74fe3, 0x0c880296, 0x06ac3e5e, 0x0cf3732b, 0x1212a4b4, 0x184de9c1,
				0x065add24, 0x0c059051, 0x12e447ce, 0x18bb0abb, 0x129f3673, 0x18c07b06, 0x0621ac99, 0x0c7ee1ec,
				0x1edc6f41, 0x14832234, 0x0a62f5ab, 0x003db8de, 0x0a198416, 0x0046c963, 0x1ea71efc, 0x14f85389,
				0x0aef676c, 0x00b02a19, 0x1e51fd86, 0x140eb0f3, 0x1e2a8c3b, 0x1475c14e, 0x0a9416d1, 0x00cb5ba4,
				0x0b02a198, 0x015deced, 0x1fbc3b72, 0x15e37607, 0x1fc74acf, 0x159807ba, 0x0b79d025, 0x01269d50,
				0x1f31a9b5, 0x156ee4c0, 0x0b8f335f, 0x01d07e2a, 0x0bf442e2, 0x01ab0f97, 0x1f4ad808, 0x1515957d,
				0x08d92c70, 0x02866105, 0x1c67b69a, 0x1638fbef, 0x1c1cc727, 0x16438a52, 0x08a25dcd, 0x02fd10b8,
				0x1cea245d, 0x16b56928, 0x0854beb7, 0x020bf3c2, 0x082fcf0a, 0x0270827f, 0x1c9155e0, 0x16ce1895,
				0x1d07e2a9, 0x1758afdc, 0x09b97843, 0x03e63536, 0x09c209fe, 0x039d448b, 0x1d7c9314, 0x1723de61,
				0x0934ea84, 0x036ba7f1, 0x1d8a706e, 0x17d53d1b, 0x1df101d3, 0x17ae4ca6, 0x094f9b39, 0x0310d64c,
				0x0f6e37a0, 0x05317ad5, 0x1bd0ad4a, 0x118fe03f, 0x1babdcf7, 0x11f49182, 0x0f15461d, 0x054a0b68,
				0x1b5d3f8d, 0x110272f8, 0x0fe3a567, 0x05bce812, 0x0f98d4da, 0x05c799af, 0x1b264e30, 0x11790345,
				0x1ab0f979, 0x10efb40c, 0x0e0e6393, 0x04512ee6, 0x0e75122e, 0x042a5f5b, 0x1acb88c4, 0x1094c5b1,
				0x0e83f154, 0x04dcbc21, 0x1a3d6bbe, 0x106226cb, 0x1a461a03, 0x10195776, 0x0ef880e9, 0x04a7cd9c,
				0x196b7491, 0x133439e4, 0x0dd5ee7b, 0x078aa30e, 0x0dae9fc6, 0x07f1d2b3, 0x1910052c, 0x134f4859,
				0x0d587cbc, 0x070731c9, 0x19e6e656, 0x13b9ab23, 0x199d97eb, 0x13c2da9e, 0x0d230d01, 0x077c4074,
				0x0cb5ba48, 0x06eaf73d, 0x180b20a2, 0x12546dd7, 0x1870511f, 0x122f1c6a, 0x0ccecbf5, 0x06918680,
				0x1886b265, 0x12d9ff10, 0x0c38288f, 0x066765fa, 0x0c435932, 0x061c1447, 0x18fdc3d8, 0x12a28ead,
			};

			crc = ~crc;
			for(size_t i = 0; i < bytes; i++) crc = (crc >> 8) ^ LUT[(crc & 0xFF) ^ (*data++)];
			return ~crc;
		}
		uint32_t crc32c(char const * data, size_t bytes, uint32_t crc = 0x00000000) {return crc32c((unsigned char const *)data, bytes, crc);}
	}

	//@brief    : compute the CRC-32C hash of this data block
	//@param crc: initial hash value
	//@return   : new hash value
	uint32_t CompoundData::computeHash(uint32_t crc) const {return detail::crc32c(std::vector<char>::data(), std::vector<char>::size(), crc);}


	////////////////////////////////////////////////////////////////////////////////
	//                               SimulationData                               //
	////////////////////////////////////////////////////////////////////////////////

	//@brief    : factory method to build known vendor specific simulation meta data types
	//@param mod: modality
	//@param ven: vendor
	//@return   : unique pointer allocated with vendor specific type (or NULL)
	std::unique_ptr<SimulationData> SimulationData::Factory(const Modality mod, const Vendor ven) {
		std::unique_ptr<SimulationData> ptr;//null pointer
		switch(ven) {
			case Vendor::Unknown:
			default             : break;

			case Vendor::EMsoft :
				switch(mod) {
					case Modality::EBSD   ://intentional fall through
					case Modality::ECP    ://intentional fall through
					case Modality::TKD    : ptr = std::unique_ptr<EMsoftED>(new EMsoftED); break;

					case Modality::Unknown://intentional fall through
					case Modality::PED    ://intentional fall through
					case Modality::Laue   ://intentional fall through
					default               : break;
				}
			break;
		}
		if(NULL != ptr.get()) {//a pointer was actually assigned, sanity check
			if(!ptr->forModality(mod) || ptr->getVendor() != ven) throw std::logic_error("simulation data fetched for modality/vendor doesn't match");
		}
		return ptr;
	}

	////////////////////////////////////////////////////////////////////////////////
	//                                 FileHeader                                 //
	////////////////////////////////////////////////////////////////////////////////

	//@brief: constructor sets size and magic bytes
	FileHeader::FileHeader() : CompoundData(40) {
		char* p = magicBytes();
		if(SysBig()) {
			p[0] = '*'; p[1] = 'S'; p[2] = 'H'; p[3] = 'T';
		} else {
			p[0] = '*'; p[1] = 's'; p[2] = 'h'; p[3] = 't';
		}
		fileVersion()[0] = VERSION_MAJOR; fileVersion()[1] = VERSION_MINOR;
		p = softwareVersion();
		std::copy(VersionString, VersionString + 8, p);
	}

	//@brief: sanity check the contents of this data block (throw if not)
	void FileHeader::sanityCheck() const {
		//check file version and reserved bytes
		if(VERSION_MAJOR != fileVersion()[0] || VERSION_MINOR != fileVersion()[1]) throw std::runtime_error("unsupported file version");
		if(0 != resBytes()[0] || 0 != resBytes()[1]) throw std::runtime_error("non-zero reserved bytes");

		switch(modality()) {
			case Modality::Unknown: break;
			case Modality::EBSD   : break;
			case Modality::ECP    : break;
			case Modality::TKD    : break;
			case Modality::PED    : break;
			case Modality::Laue   : break;
			default: throw std::runtime_error("invalid modality flag");       
		}
		for(size_t i = 0; i < 3; i++) if(0 != resBytes2()[i]) throw std::runtime_error("reserved bytes must be 0");

		//check string lengths
		int16_t dSz = doiLen ();
		int16_t nSz = noteLen();
		if(0 != dSz % 8) dSz += 8 - (dSz % 8);
		if(0 != nSz % 8) nSz += 8 - (nSz % 8);
		if(doi  .size() != dSz) throw std::runtime_error("doi string doesn't match length");
		if(notes.size() != nSz) throw std::runtime_error("noites string doesn't match length");

		//check physical parameters
		if(beamEnergy() <     0.0f) throw std::runtime_error("negative beam energy is non-physical");
		if(beamEnergy() > 10000.0f) throw std::runtime_error("10 MeV beam energy is unrealistic");
		if(primaryAngle() < -360.0f || primaryAngle() > 360.0f) throw std::runtime_error("primary angle outside [-360,360]");
		if(secondaryAngle() < -360.0f || secondaryAngle() > 360.0f) throw std::runtime_error("secondary angle outside [-360,360]");
	}

	//@brief    : compute the CRC-32C hash of this data block
	//@param crc: initial hash value
	//@return   : new hash value
	uint32_t FileHeader::computeHash(uint32_t crc) const {
		crc = CompoundData::computeHash(crc);//start by hashing fixed length part
		if(!doi.empty()) crc = detail::crc32c(doi.data(), doi.size(), crc);
		if(!notes.empty()) crc = detail::crc32c(notes.data(), notes.size(), crc);
		return crc;
	}

	//@brief   : write data to an ostream
	//@param os: ostream to write to
	//@return  : os
	std::ostream& FileHeader::write(std::ostream& os) const {
		if(!CompoundData::write(os)) throw std::runtime_error("failed to write fixed size sht::FileHeader component");
		if(!doi.empty()) {//write doi string if needed
			if(!os.write(doi.data(), doi.size())) throw std::runtime_error("failed to write doi string");
		}
		if(!notes.empty()) {//write note string if needed
			if(!os.write(notes.data(), notes.size())) throw std::runtime_error("failed to write notes string");
		}
		return os;
	}

	//@brief    : read data from an istream
	//@param is : istream to read from
	//@param swp: does the input stream need to be byte swapped (is the endedness mismatched)
	//@return   : is
	std::istream& FileHeader::read(std::istream& is, const bool swp) {
		//read fixed length part
		if(!CompoundData::read(is, swp)) throw std::runtime_error("failed to read fixed size sht::FileHeader component");

		//resize strings
		int16_t dSz = doiLen ();
		int16_t nSz = noteLen();
		if(endianMismatch()) {
			dSz = detail::byteSwap(dSz);
			nSz = detail::byteSwap(nSz);
		}
		if(0 != dSz % 8) dSz += 8 - (dSz % 8);
		if(0 != nSz % 8) nSz += 8 - (nSz % 8);
		doi  .resize(dSz, 0);
		notes.resize(nSz, 0);

		//read strings
		if(!doi.empty()) {//read doi string if needed
			if(!is.read((char*)doi.data(), doi.size())) throw std::runtime_error("failed to read doi string");
		}
		if(!notes.empty()) {//read note string if needed
			if(!is.read((char*)notes.data(), notes.size())) throw std::runtime_error("failed to read notes string");
		}
		return is;
	}

	//@brief: byte swap data
	void FileHeader::byteSwap() {
		doiLen        () = detail::byteSwap(doiLen        ());
		noteLen       () = detail::byteSwap(noteLen       ());
		beamEnergy    () = detail::byteSwap(beamEnergy    ());
		primaryAngle  () = detail::byteSwap(primaryAngle  ());
		secondaryAngle() = detail::byteSwap(secondaryAngle());
		reservedParam () = detail::byteSwap(reservedParam ());
	}

	//@brief : check if the file is big/little endian using magic bytes
	//@return: true if big endian, false if little
	bool FileHeader::fileBig() const {
		char const * const b = magicBytes();
		if     ('*' == b[0] && 's' == b[1] && 'h' == b[2] && 't' == b[3]) return false;
		else if('*' == b[0] && 'S' == b[1] && 'H' == b[2] && 'T' == b[3]) return true ;
		else throw std::runtime_error("invalid magic bytes (not a SHT file");
	}

	//@brief : check if the the system is big/little endian
	//@return: true if big endian, false if little
	bool FileHeader::SysBig() {
		union {
			uint32_t i   ;
			char     c[4];
		} u = {0x01020304};
		return u.c[0] == 1;
	}

	//@brief    : set the DOI string
	//@param str: new DOI string
	void FileHeader::setDoi(std::string str) {
		doi = str;
		if(str.size() > (size_t)std::numeric_limits<int16_t>::max()) throw std::runtime_error("string too long for 16 bit length");
		doiLen() = (int16_t)str.size();
		size_t pad = str.size() % 8;
		if(pad != 0) doi.resize(str.size() + 8 - pad, 0);
	}

	//@brief    : set the notes string
	//@param str: new notes string
	void FileHeader::setNotes(std::string str) {
		notes = str;
		if(str.size() > (size_t)std::numeric_limits<int16_t>::max()) throw std::runtime_error("string too long for 16 bit length");
		noteLen() = (int16_t)str.size();
		size_t pad = str.size() % 8;
		if(pad != 0) notes.resize(str.size() + 8 - pad, 0);
	}

	////////////////////////////////////////////////////////////////////////////////
	//                                  AtomData                                  //
	////////////////////////////////////////////////////////////////////////////////

	//@brief: sanity check the contents of this data block (throw if not)
	void AtomData::sanityCheck() const {
		if(x() < 0.0f || x() >= 24.0f) throw std::runtime_error("atom x coordinate outside of [0,a)");
		if(y() < 0.0f || y() >= 24.0f) throw std::runtime_error("atom y coordinate outside of [0,b)");
		if(z() < 0.0f || z() >= 24.0f) throw std::runtime_error("atom z coordinate outside of [0,c)");
		if(occ() <= 0.0f || z() > 1.0f) throw std::runtime_error("atom occupancy outside of (0,1]");
		if(charge() < -18 || charge() > atZ()) throw std::runtime_error("atom charge outsize of [-18,+Z]");
		if(debWal() < 0.0f) throw std::runtime_error("negative Debye-Waller factor is un-physical");
		if(atZ() < 1 || atZ() > 118) throw std::runtime_error("atomic number is outsize of [1,118]");
		if(0 != resBytes()[0] || 0 != resBytes()[1] || 0 != resBytes()[2]) throw std::runtime_error("non-zero reserved bytes");
	}

	//@brief: byte swap data
	void AtomData::byteSwap() {
		x     () = detail::byteSwap(x     ());
		y     () = detail::byteSwap(y     ());
		z     () = detail::byteSwap(z     ());
		occ   () = detail::byteSwap(occ   ());
		charge() = detail::byteSwap(charge());
		debWal() = detail::byteSwap(debWal());
		resFp () = detail::byteSwap(resFp ());
	}
	
	////////////////////////////////////////////////////////////////////////////////
	//                                CrystalData                                 //
	////////////////////////////////////////////////////////////////////////////////

	//@brief: sanity check the contents of this data block (throw if not)
	void CrystalData::sanityCheck() const {
		//check space group number and origin setting
		if(sgNum() < 1 || sgNum() > 230) throw std::runtime_error("space group number outside [1,230]");
		if( 48 == sgNum() ||  50 == sgNum() ||  59 == sgNum() ||  68 == sgNum() ||
		    70 == sgNum() ||  85 == sgNum() ||  86 == sgNum() ||  88 == sgNum() ||
		   125 == sgNum() || 126 == sgNum() || 129 == sgNum() || 130 == sgNum() ||
		   133 == sgNum() || 134 == sgNum() || 137 == sgNum() || 138 == sgNum() ||
		   141 == sgNum() || 142 == sgNum() || 201 == sgNum() || 203 == sgNum() ||
		   222 == sgNum() || 224 == sgNum() || 227 == sgNum() || 228 == sgNum()) {//2 origin settings
			if(sgSet() < 1 || sgSet() > 2) throw std::runtime_error("invalid space group setting");
		} else {//1 origin setting
			if(1 != sgSet()) throw std::runtime_error("invalid space group setting");
		}

		//check space group axis
		if     (sgNum() >  2 && sgNum() < 16) {//monoclinic
			switch(sgAxis()) {
				case Axis::Mono_B :
				case Axis::Mono_nB:
				case Axis::Mono_C :
				case Axis::Mono_nC:
				case Axis::Mono_A :
				case Axis::Mono_nA: break;
				default: throw std::runtime_error("invalid monoclinic axis");
			}
		} else if(sgNum() > 15 && sgNum() < 75) {//orthorhombic
			switch(sgAxis()) {
				case Axis::Orth_ABC:
				case Axis::Orth_BAC:
				case Axis::Orth_CAB:
				case Axis::Orth_CBA:
				case Axis::Orth_BCA:
				case Axis::Orth_ACB: break;
				default: throw std::runtime_error("invalid orthorhombic axis");
			}
		} else {//all other groups
			if(Axis::Default != sgAxis()) throw std::runtime_error("non monoclinic/orthorhombic groups must have default axis");
		}

		//check space group cell
		if( 5 == sgNum() ||  7 == sgNum() ||  9 == sgNum() || 12 == sgNum() ||
		   13 == sgNum() || 14 == sgNum() || 15 == sgNum()) {//multi cell monoclinic
		   	switch(sgCell()) {
		   		case Cell::Mono_1:
		   		case Cell::Mono_2:
		   		case Cell::Mono_3: break;
		   		default: throw std::runtime_error("invalid cell choice for multi-cell monoclinic");
		   	}
		} else if(146 == sgNum() || 148 == sgNum() || 155 == sgNum() || 160 == sgNum() ||
			      161 == sgNum() || 166 == sgNum() || 167 == sgNum()) {//rhomobhedral setting
			switch(sgCell()) {
				case Cell::Trig_Hex:
				case Cell::Trig_Rhm: break;
				default: throw std::runtime_error("invalid cell choice for rhomobhedral trigonal group");
			}
		} else if(sgNum() >  74 && sgNum() < 143) {//tetragonal
			switch(sgCell()) {
				case Cell::Default:
				case Cell::Tet_CF : break;
				default: throw std::runtime_error("invalid cell choice for tetragonal");
			}
		} else if(sgNum() > 142 && sgNum() < 195) {//primitive trig/hex group
			switch(sgCell()) {
				case Cell::Default  :
				case Cell::TrigHex_H: break;
				default: throw std::runtime_error("invalid cell choice for non-rhombohedral trigonal/hexagonal group");
			}
		} else {//primitive trig/hex group
			switch(sgCell()) {
				case Cell::Default: break;
				default: throw std::runtime_error("invalid cell choice for generic group");
			}
		}

		//sanity check origin shift
		if(oriX() < -24.0f || oriX() > 24.0f) throw std::runtime_error("x origin translation outside [-a, a]");
		if(oriY() < -24.0f || oriY() > 24.0f) throw std::runtime_error("y origin translation outside [-b, b]");
		if(oriZ() < -24.0f || oriZ() > 24.0f) throw std::runtime_error("z origin translation outside [-c, c]");
		
		//sanity check lattice parameters
		for(size_t i = 0; i < 3; i++) {
			if(lat()[  i] <= 0.0f || lat()[  i] >= 10000.0f) throw std::runtime_error("lattice length outside (0, 10) microns");//maybe someone has a very strange huge unit cell...
			if(lat()[3+i] <= 0.0f || lat()[3+i] >=   180.0f) throw std::runtime_error("lattice angle outside (0, 180) degrees");
		}

		//sanity check rotation
		for(size_t i = 0; i < 4; i++) {
			if(rot()[i] < -1.0f || rot()[i] > 1.0f) throw std::runtime_error("quaternion element outside [-1,1]");
		}
		const float mag2 = rot()[0] * rot()[0]
		                 + rot()[1] * rot()[1]
		                 + rot()[2] * rot()[2]
		                 + rot()[3] * rot()[3];
		if(mag2 < 0.99f || mag2 > 1.01f) throw std::runtime_error("rotation not a unit quaternion");

		//sanity check atom length
		if(numAtoms() != atoms.size()) throw std::runtime_error("# atoms doesn't match atom size");

		//sanity check string lengths
		int16_t fSz = formulaLen  ();
		int16_t mSz = matNameLen  ();
		int16_t sSz = structSymLen();
		int16_t rSz = refsLen     ();
		int16_t nSz = noteLen     ();

		if(0 != fSz % 8) fSz += 8 - (fSz % 8);
		if(0 != mSz % 8) mSz += 8 - (mSz % 8);
		if(0 != sSz % 8) sSz += 8 - (sSz % 8);
		if(0 != rSz % 8) rSz += 8 - (rSz % 8);
		if(0 != nSz % 8) nSz += 8 - (nSz % 8);

		//check string lengths
		if(form.size() != fSz) throw std::runtime_error("formula string doesn't match length");
		if(name.size() != mSz) throw std::runtime_error("maerial/phase name string doesn't match length");
		if(symb.size() != sSz) throw std::runtime_error("structure symbol string doesn't match length");
		if(refs.size() != rSz) throw std::runtime_error("reference string doesn't match length");
		if(note.size() != nSz) throw std::runtime_error("note string doesn't match length");

		//sanity check individual atoms
		for(const AtomData& ad : atoms) ad.sanityCheck();
	}

	//@brief    : compute the CRC-32C hash of this data block
	//@param crc: initial hash value
	//@return   : new hash value
	uint32_t CrystalData::computeHash(uint32_t crc) const {
		crc = CompoundData::computeHash(crc);//start by hashing fixed length part
		for(const AtomData& ad : atoms) crc = ad.computeHash(crc);
		if(!form.empty()) crc = detail::crc32c(form.data(), form.size(), crc);
		if(!name.empty()) crc = detail::crc32c(name.data(), name.size(), crc);
		if(!symb.empty()) crc = detail::crc32c(symb.data(), symb.size(), crc);
		if(!refs.empty()) crc = detail::crc32c(refs.data(), refs.size(), crc);
		if(!note.empty()) crc = detail::crc32c(note.data(), note.size(), crc);
		return crc;
	}

	//@brief   : write data to an ostream
	//@param os: ostream to write to
	//@return  : os
	std::ostream& CrystalData::write(std::ostream& os) const {
		if(!CompoundData::write(os)) throw std::runtime_error("failed to write fixed size sht::CrystalData component");
		for(const AtomData& ad : atoms) if(!ad.write(os)) throw std::runtime_error("failed to write all atoms");
		if(!form.empty()) {
			if(!os.write(form.data(), form.size())) throw std::runtime_error("failed to write formula string");
		}
		if(!name.empty()) {
			if(!os.write(name.data(), name.size())) throw std::runtime_error("failed to write maerial/phase name string");
		}
		if(!symb.empty()) {
			if(!os.write(symb.data(), symb.size())) throw std::runtime_error("failed to write structure symbol string");
		}
		if(!refs.empty()) {
			if(!os.write(refs.data(), refs.size())) throw std::runtime_error("failed to write references string");
		}
		if(!note.empty()) {
			if(!os.write(note.data(), note.size())) throw std::runtime_error("failed to write note string");
		}
		return os;
	}

	//@brief    : read data from an istream
	//@param is : istream to read from
	//@param swp: does the input stream need to be byte swapped (is the endedness mismatched)
	//@return   : is
	std::istream& CrystalData::read(std::istream& is, const bool swp) {
		//read fixed length data
		if(!CompoundData::read(is, swp)) throw std::runtime_error("failed to read fixed size sht::CrystalData component");
		int16_t nAt = numAtoms    ();
		int16_t fSz = formulaLen  ();
		int16_t mSz = matNameLen  ();
		int16_t sSz = structSymLen();
		int16_t rSz = refsLen     ();
		int16_t nSz = noteLen     ();
	
		if(swp) {
			nAt = detail::byteSwap(nAt);
			fSz = detail::byteSwap(fSz);
			mSz = detail::byteSwap(mSz);
			sSz = detail::byteSwap(sSz);
			rSz = detail::byteSwap(rSz);
			nSz = detail::byteSwap(nSz);
		}
		if(0 != fSz % 8) fSz += 8 - (fSz % 8);
		if(0 != mSz % 8) mSz += 8 - (mSz % 8);
		if(0 != sSz % 8) sSz += 8 - (sSz % 8);
		if(0 != rSz % 8) rSz += 8 - (rSz % 8);
		if(0 != nSz % 8) nSz += 8 - (nSz % 8);

		//read atom data
		atoms.resize(nAt);
		for(AtomData& ad : atoms) if(!ad.read(is, swp)) throw std::runtime_error("failed to read all atoms");

		//read strings
		form.resize(fSz, 0);
		name.resize(mSz, 0);
		symb.resize(sSz, 0);
		refs.resize(rSz, 0);
		note.resize(nSz, 0);
		if(!form.empty()) {//read formula string if needed
			if(!is.read((char*)form.data(), form.size())) throw std::runtime_error("failed to read formula string");
		}
		if(!name.empty()) {//read material/phase name string if needed
			if(!is.read((char*)name.data(), name.size())) throw std::runtime_error("failed to read material/phase name string");
		}
		if(!symb.empty()) {//read structure symbol string if needed
			if(!is.read((char*)symb.data(), symb.size())) throw std::runtime_error("failed to read structure symbol string");
		}
		if(!refs.empty()) {//read structure symbol string if needed
			if(!is.read((char*)refs.data(), refs.size())) throw std::runtime_error("failed to read structure symbol string");
		}
		if(!note.empty()) {//read structure symbol string if needed
			if(!is.read((char*)note.data(), note.size())) throw std::runtime_error("failed to read structure symbol string");
		}
		return is;
	}

	//@brief: byte swap data
	void CrystalData::byteSwap() {
		float * const pLat = lat();
		float * const pRot = rot();
		oriX    () = detail::byteSwap(oriX    ());
		oriY    () = detail::byteSwap(oriY    ());
		oriZ    () = detail::byteSwap(oriZ    ());
		for(size_t i = 0; i < 6; i++) pLat[i] = detail::byteSwap(pLat[i]);
		for(size_t i = 0; i < 4; i++) pRot[i] = detail::byteSwap(pRot[i]);
		weight  () = detail::byteSwap(weight  ());
		numAtoms() = detail::byteSwap(numAtoms());
		numAtoms    () = detail::byteSwap(numAtoms    ());
		formulaLen  () = detail::byteSwap(formulaLen  ());
		matNameLen  () = detail::byteSwap(matNameLen  ());
		structSymLen() = detail::byteSwap(structSymLen());
		refsLen     () = detail::byteSwap(refsLen     ());
		noteLen     () = detail::byteSwap(noteLen     ());
		for(AtomData& ad : atoms) ad.byteSwap();
	}

	//@brief    : set the formula string
	//@param str: new formula string
	void CrystalData::setFormula(std::string str) {
		form = str;
		if(str.size() > (size_t)std::numeric_limits<int16_t>::max()) throw std::runtime_error("string too long for 16 bit length");
		formulaLen() = (int16_t)str.size();
		size_t pad = str.size() % 8;
		if(pad != 0) form.resize(str.size() + 8 - pad, 0);
	}

	//@brief    : set the material/phase name string
	//@param str: new material/phase name string
	void CrystalData::setName(std::string str) {
		name = str;
		if(str.size() > (size_t)std::numeric_limits<int16_t>::max()) throw std::runtime_error("string too long for 16 bit length");
		matNameLen() = (int16_t)str.size();
		size_t pad = str.size() % 8;
		if(pad != 0) name.resize(str.size() + 8 - pad, 0);
	}

	//@brief    : set the structure symbol string
	//@param str: new structure symbol string
	void CrystalData::setStructSym(std::string str) {
		symb = str;
		if(str.size() > (size_t)std::numeric_limits<int16_t>::max()) throw std::runtime_error("string too long for 16 bit length");
		structSymLen() = (int16_t)str.size();
		size_t pad = str.size() % 8;
		if(pad != 0) symb.resize(str.size() + 8 - pad, 0);
	}

	//@brief    : set the references string
	//@param str: new references string
	void CrystalData::setRefs(std::string str) {
		refs = str;
		if(str.size() > (size_t)std::numeric_limits<int16_t>::max()) throw std::runtime_error("string too long for 16 bit length");
		refsLen() = (int16_t)str.size();
		size_t pad = str.size() % 8;
		if(pad != 0) refs.resize(str.size() + 8 - pad, 0);
	}

	//@brief    : set the note string
	//@param str: new note string
	void CrystalData::setNote(std::string str) {
		note = str;
		if(str.size() > (size_t)std::numeric_limits<int16_t>::max()) throw std::runtime_error("string too long for 16 bit length");
		noteLen() = (int16_t)str.size();
		size_t pad = str.size() % 8;
		if(pad != 0) note.resize(str.size() + 8 - pad, 0);
	}

	////////////////////////////////////////////////////////////////////////////////
	//                                MasterPatternData                                //
	////////////////////////////////////////////////////////////////////////////////

	//@brief: sanity check the contents of this data block (throw if not)
	void MasterPatternData::sanityCheck() const {
		if(sgEff() < 1 || sgEff() > 230) throw std::runtime_error("invalid effective space group number");
		if(numXtal() != xtals.size()) throw std::runtime_error("# crystals != crystals size");
		if(numXtal() != simul.size()) throw std::runtime_error("# crystals != simulation metadata size");
		if(! (1 == pijk() || -1 == pijk())) throw std::runtime_error("pijk must be +/-1");
		if(! (97 == rotSense() || 112 == rotSense())) throw std::runtime_error("rotation sense must be 'a' or 'p'");
		switch(modality()) {
			case Modality::Unknown: break;
			case Modality::EBSD   : break;
			case Modality::ECP    : break;
			case Modality::TKD    : break;
			case Modality::PED    : break;
			case Modality::Laue   : break;
			default: throw std::runtime_error("invalid modality flag");       
		}
		switch(vendor()) {
			case Vendor::Unknown: break;
			case Vendor::EMsoft : break;
			default: throw std::runtime_error("invalid vendor flag");       
		}
		if(0 == simMetaSize()) {
			for(const std::unique_ptr<SimulationData>& p : simul) {
				if(NULL != p.get()) throw std::runtime_error("non-NULL simulation data for 0 size");
			}
		} else {
			for(const std::unique_ptr<SimulationData>& p : simul) {
				if(NULL == p.get()) throw std::runtime_error("NULL simulation data for nonzero size");
				if(p->size() != simMetaSize()) throw std::runtime_error("simulation data size doesn't match header size");
				if(!p->forModality(modality())) throw std::runtime_error("simulation data modality not valid for master pattern modality");
				if(p->getVendor() != vendor()) throw std::runtime_error("simulation data vendor doesn't match master pattern verndor");
			}
		}
	}

	//@brief    : compute the CRC-32C hash of this data block
	//@param crc: initial hash value
	//@return   : new hash value
	uint32_t MasterPatternData::computeHash(uint32_t crc) const {
		crc = CompoundData::computeHash(crc);//start by hashing fixed length part
		for(const CrystalData& x : xtals) crc = x.computeHash(crc);
		if(0 != simMetaSize()) {
			for(const std::unique_ptr<SimulationData>& p : simul) {
				if(NULL == p.get()) throw std::runtime_error("NULL simulation data for nonzero size");
				crc = p->computeHash(crc);
			}
		}
		return crc;
	}

	//@brief   : write data to an ostream
	//@param os: ostream to write to
	//@return  : os
	std::ostream& MasterPatternData::write(std::ostream& os) const {
		if(!CompoundData::write(os)) throw std::runtime_error("failed to write fixed size sht::MasterPatternData component");
		for(const CrystalData& x : xtals) if(!x.write(os)) throw std::runtime_error("failed to write all crystals");
		if(0 != simMetaSize()) {
			for(const std::unique_ptr<SimulationData>& p : simul) {
				if(NULL == p.get()) throw std::runtime_error("NULL simulation data for nonzero size");
				if(!p->write(os)) throw std::runtime_error("failed to write all simulation metadata");
			}
		}
		return os;
	}

	//@brief    : read data from an istream
	//@param is : istream to read from
	//@param swp: does the input stream need to be byte swapped (is the endedness mismatched)
	//@return   : is
	std::istream& MasterPatternData::read(std::istream& is, const bool swp) {
		if(!CompoundData::read(is, swp)) throw std::runtime_error("failed to read fixed size sht::CrystalData component");
		xtals.resize(numXtal());//8 bit, no swap needed
		simul.resize(numXtal());//8 bit, no swap needed
		for(CrystalData& x : xtals) if(!x.read(is, swp)) throw std::runtime_error("failed to read all crystals");
		if(0 != simMetaSize()) {//dont need to byteswap since 0 is a palindrome
			std::unique_ptr<SimulationData> data = SimulationData::Factory(modality(), vendor());
			if(NULL != data.get()) {
				if(data->size() != simMetaSize()) throw std::runtime_error("simulation data size mismatch");
				for(std::unique_ptr<SimulationData>& p : simul) {
					p = SimulationData::Factory(modality(), vendor());
					if(!p->read(is, swp)) throw std::runtime_error("failed to read all simulation data");
				}
			} else {
				throw std::runtime_error("unable to construct simulation meta data for modality/vendor pair");//could read into byte buffer and compute hash instead
			}
		}
		return is;
	}

	//@brief: byte swap data
	void MasterPatternData::byteSwap() {
		simMetaSize() = detail::byteSwap(simMetaSize());
		for(CrystalData& x : xtals) x.byteSwap();
		for(std::unique_ptr<SimulationData>& p : simul) {
			if(NULL != p.get()) p->byteSwap();
		}
	}

	////////////////////////////////////////////////////////////////////////////////
	//                               HarmonicsData                                //
	////////////////////////////////////////////////////////////////////////////////

	//@brief: sanity check the contents of this data block (throw if not)
	void HarmonicsData::sanityCheck() const {
		if(doubCnt() != NumHarm(bw(), zRot(), cmpFlg() ) ) throw std::runtime_error("harmonics count doesn't match compression parameters");
		if(doubCnt() != alm.size()) throw std::runtime_error("harmonics count doesn't match size");
	}

	//@brief    : compute the CRC-32C hash of this data block
	//@param crc: initial hash value
	//@return   : new hash value
	uint32_t HarmonicsData::computeHash(uint32_t crc) const {
		crc = CompoundData::computeHash(crc);//start by hashing fixed length part
		for(const double& d : alm) crc = detail::crc32c((char*)&d, 8, crc); 
		return crc;
	}

	//@brief   : write data to an ostream
	//@param os: ostream to write to
	//@return  : os
	std::ostream& HarmonicsData::write(std::ostream& os) const {
		if(!CompoundData::write(os)) throw std::runtime_error("failed to write fixed size sht::HarmonicsData component");
		if(!os.write((char*)alm.data(), alm.size() * 8)) throw std::runtime_error("failed to write all harmonics");
		return os;
	}

	//@brief    : read data from an istream
	//@param is : istream to read from
	//@param swp: does the input stream need to be byte swapped (is the endedness mismatched)
	//@return   : is
	std::istream& HarmonicsData::read(std::istream& is, const bool swp) {
		if(!CompoundData::read(is, swp)) throw std::runtime_error("failed to read fixed size sht::CrystalData component");
		int32_t dCnt = doubCnt();
		if(swp) dCnt = detail::byteSwap(dCnt);
		alm.resize(dCnt);
		if(!is.read((char*)alm.data(), alm.size() * 8)) throw std::runtime_error("failed to read all harmonics");
		return is;
	}

	//@brief: byte swap data
	void HarmonicsData::byteSwap() {
		bw() = detail::byteSwap(bw());
		for(double& d : alm) d = detail::byteSwap(d);
	}

	//@brief  : compute the number of non-zero spherical harmonic transform coefficients
	//@param b: bandwidth to compute for
	//@param n: z rotational order
	//@param f: compression flag
	//@return : the number of harmonic coefficients (# doubles)
	uint32_t HarmonicsData::NumHarm(const int16_t b, const int8_t n, const int8_t f) {
		//extract compression flags
		const bool inv  = 0x01 == (f & 0x01);
		const bool mirZ = 0x02 == (f & 0x02);
		const bool mirY = 0x04 == (f & 0x04);//Nmm type group
		const bool mirX = 0x08 == (f & 0x08);//rotated Nmm type group
		if(mirX && mirY) throw std::runtime_error("compression flags 0x04 and 0x08 are mutually exclusive");//zRot probably needs to be doubled instead

		//start by counting location of non zero magnitude complex doubles
		uint32_t num = 0;
		for(uint16_t m = 0; m < b; m++) {
			if(n > 1 ? 0 != m % n : false) continue;//this m is systemic zeros
			for(uint16_t l = m; l < b; l++) {
				if(inv  && 0 != l % 2) continue;//inversion symmetry forbidden
				if(mirZ && 0 != (l + m) % 2) continue;//mirror plane forbidden
				++num;
			}
		}

		//convert to number of doubles
		if(mirX || mirY) {
			//complex doubles are all either purely real or imaginary
		} else {
			num *= 2;//actually complex valued
		}
		return num;
	}

	//@brief    : compress spherical harmonics
	//@param in : harmonics to compress with m, l at in[m * bw + l]
	//@param out: location to write compressed coefficients
	//@param b  : bandwidth
	//@param n  : z rotational order
	//@param f  : compression flag
	template <typename Real>
	void HarmonicsData::PackHarm(std::complex<Real> const * in, Real * out, const int16_t b, const int8_t n, const int8_t f) {
		//extract compression flags
		const bool inv  = 0x01 == (f & 0x01);
		const bool mirZ = 0x02 == (f & 0x02);
		const bool mirY = 0x04 == (f & 0x04);//Nmm type group
		const bool mirX = 0x08 == (f & 0x08);//rotated Nmm type group
		if(mirX && mirY) throw std::runtime_error("compression flags 0x04 and 0x08 are mutually exclusive");//zRot probably needs to be doubled instead

		//do compression
		const size_t bw = (size_t) b;
		for(size_t m = 0; m < bw; m++) {
			std::complex<double> const * row = in + m * bw;//get pointer to row start
			if(n > 1 ? 0 != m % n : false) continue;//systemic zeros

			//compress row of constant m depending on flags
			int type = 0;//complex
			if(mirY) {
				type = 1;//strictly real
			} else if(mirX) {
				if(m % (n * 2) == 0) {
					type = 1;//strictly real
				} else {
					type = 2;//strictly imaginary
				}
			}

			switch(type) {
				case 0://complex
					for(size_t l = m; l < bw; l++) {
						if( (inv && 0 != l % 2) || (mirZ && 0 != (l + m) % 2) ) continue;
						*out++ = row[l].real();
						*out++ = row[l].imag();
					}
				break;

				case 1://real
					for(size_t l = m; l < bw; l++) {
						if( (inv && 0 != l % 2) || (mirZ && 0 != (l + m) % 2) ) continue;
						*out++ = row[l].real();
					}
				break;

				case 2://imaginary
					for(size_t l = m; l < bw; l++) {
						if( (inv && 0 != l % 2) || (mirZ && 0 != (l + m) % 2) ) continue;
						*out++ = row[l].imag();
					}
				break;
			}
		}
	}

	//@brief    : decompress spherical harmonics
	//@param in : compressed coefficients to unpack
	//@param out: location to write uncompressed harmoincs harmonics with m, l at out[m * bw + l]
	//@param b  : bandwidth
	//@param n  : z rotational order
	//@param f  : compression flag
	template <typename Real>
	void HarmonicsData::UnpackHarm(Real const * in, std::complex<Real> * out, const int16_t b, const int8_t n, const int8_t f) {
		//extract compression flags
		const bool inv  = 0x01 == (f & 0x01);
		const bool mirZ = 0x02 == (f & 0x02);
		const bool mirY = 0x04 == (f & 0x04);//Nmm type group
		const bool mirX = 0x08 == (f & 0x08);//rotated Nmm type group
		if(mirX && mirY) throw std::runtime_error("compression flags 0x04 and 0x08 are mutually exclusive");//zRot probably needs to be doubled instead

		//do uncompression			
		const size_t bw = (size_t) b;
		for(size_t m = 0; m < bw; m++) {
			std::complex<Real> * const row = out + bw * m;
			if(n > 1 ? 0 != m % n : false) {//systemic zeros
				std::fill(row, row + bw, std::complex<Real>(0));
			} else {//non-zero
				std::fill(row, row + m, std::complex<Real>(0));//padding for nice alignment

				//compress row of constant m depending on flags
				int type = 0;//complex
				if(mirY) {
					type = 1;//strictly real
				} else if(mirX) {
					if(m % (n * 2) == 0) {
						type = 1;//strictly real
					} else {
						type = 2;//strictly imaginary
					}
				}

				switch(type) {
					case 0://complex
						for(size_t l = m; l < bw; l++) {
							if( (inv && 0 != l % 2) || (mirZ && 0 != (l + m) % 2) ) {//systemic zero
								row[l] = std::complex<Real>(0);
							} else {
								row[l].real(*in++);
								row[l].imag(*in++);
							}
						}
					break;

					case 1://real
						for(size_t l = m; l < bw; l++) {
							if( (inv && 0 != l % 2) || (mirZ && 0 != (l + m) % 2) ) {//systemic zero
								row[l] = std::complex<Real>(0);
							} else {
								row[l].real(*in++);
								row[l].imag(Real(0));
							}
						}
					break;

					case 2://imaginary
						for(size_t l = m; l < bw; l++) {
							if( (inv && 0 != l % 2) || (mirZ && 0 != (l + m) % 2) ) {//systemic zero
								row[l] = std::complex<Real>(0);
							} else {
								row[l].real(Real(0));
								row[l].imag(*in++);
							}
						}
					break;
				}
			}
		}
	}

	//@brief   : get the z rotational order for a given space group
	//@param sg: space group number
	//@return  : z rotational order
	//@note    : assumes standard settings (monoclinic unique axis b, orthorhombic axis choice abc)
	int8_t HarmonicsData::SpaceGroupRot(const uint8_t sg) {
		static const int8_t rot[230] = {
			1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,
			2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
			2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
			2,2,2,2,2,4,4,4,4,4,4,2,2,4,4,4,4,4,4,4,4,4,4,
			4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,
			2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
			4,4,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
			3,3,3,3,3,3,6,6,6,6,6,6,3,6,6,6,6,6,6,6,6,6,6,
			6,6,3,3,3,3,6,6,6,6,2,2,2,2,2,2,2,2,2,2,2,2,4,
			4,4,4,4,4,4,4,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4
		};
		return rot[sg-1];
	}

	//@brief   : get the compression flags for a given space group
	//@param sg: space group number
	//@return  : compression bitmask
	//@note    : assumes standard settings (monoclinic unique axis b, orthorhombic axis choice abc)
	int8_t HarmonicsData::SpaceGroupCmp(const uint8_t sg) {
		static const int8_t cmp[230] = {
			0x0,0x1,0x0,0x0,0x0,0x4,0x4,0x4,0x4,0x5,0x5,0x5,0x5,0x5,0x5,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
			0x0,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,
			0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,
			0x7,0x7,0x7,0x7,0x7,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x3,0x3,0x3,0x3,0x3,0x3,0x0,0x0,0x0,0x0,
			0x0,0x0,0x0,0x0,0x0,0x0,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x8,0x8,0x8,0x8,0x4,
			0x4,0x4,0x4,0x4,0x4,0x8,0x8,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,
			0x7,0x7,0x7,0x7,0x0,0x0,0x0,0x0,0x1,0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x8,0x4,0x8,0x4,0x8,0x8,
			0x5,0x5,0x9,0x9,0x9,0x9,0x0,0x0,0x0,0x0,0x0,0x0,0x2,0x3,0x3,0x0,0x0,0x0,0x0,0x0,0x0,0x4,0x4,
			0x4,0x4,0xA,0xA,0x6,0x6,0x7,0x7,0x7,0x7,0x0,0x0,0x0,0x0,0x0,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x0,
			0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x8,0x8,0x8,0x8,0x8,0x8,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,
		};
		return cmp[sg-1];
	}

	////////////////////////////////////////////////////////////////////////////////
	//                                  EMsoftED                                  //
	////////////////////////////////////////////////////////////////////////////////

	//@brief  : check if this datatype supports a given modality
	//@param m: modality to check support for
	//@return : true if the data type supports m, false otherwise
	bool EMsoftED::forModality(const Modality& m) const {
		switch(m) {
			case Modality::EBSD:
			case Modality::ECP :
			case Modality::TKD : return true ;
			default            : return false;
		}
	}

	//@brief: byte swap data
	void EMsoftED::byteSwap() {
		sigStart () = detail::byteSwap(sigStart ());
		sigEnd   () = detail::byteSwap(sigEnd   ());
		sigStep  () = detail::byteSwap(sigStep  ());
		omega    () = detail::byteSwap(omega    ());
		keV      () = detail::byteSwap(keV      ());
		eHistMin () = detail::byteSwap(eHistMin ());
		eBinSize () = detail::byteSwap(eBinSize ());
		depthMax () = detail::byteSwap(depthMax ());
		depthStep() = detail::byteSwap(depthStep());
		thickness() = detail::byteSwap(thickness());
		totNumEl () = detail::byteSwap(totNumEl ());
		numSx    () = detail::byteSwap(numSx    ());
		c1       () = detail::byteSwap(c1       ());
		c2       () = detail::byteSwap(c2       ());
		c3       () = detail::byteSwap(c3       ());
		sigDbDiff() = detail::byteSwap(sigDbDiff());
		dMin     () = detail::byteSwap(dMin     ());
		numPx    () = detail::byteSwap(numPx    ());
	}

	void EMsoftED::sanityCheck() const {
		//sanity check monte carlo components
		if(sigStart() < -180.0f || sigStart() > 180.0f) throw std::runtime_error("beam angles should be in [-180, 180] um");
		if(sigEnd() < -180.0f || sigEnd() > 180.0f) throw std::runtime_error("beam angles should be in [-180, 180] um");
		if(sigStep() > std::fabs(sigStart() - sigEnd())) throw std::runtime_error("beam angle step > beam angle range");
		if(sigEnd() < -360.0f || sigEnd() > 360.0f) throw std::runtime_error("secondary angle should be in [-360, 360] um");
		if(numSx() < 3 || numSx() > 5000) throw std::runtime_error("monte carlo grid size outside [3, 5000]");
		if(keV() < 0 || keV() > 1000) throw std::runtime_error("max accelerating voltage should be in [0, 1000] kV");
		if(eHistMin() < 0 || eHistMin() > keV()) throw std::runtime_error("min accelerating voltage should be in [0, maxKv]");
		if(eBinSize() < 0 || eBinSize() > keV()) throw std::runtime_error("accelerating voltage step should be in [0, maxKv]");
		if(depthMax() < 0 || depthMax() > 100000) throw std::runtime_error("max depth should be in [0, 100] um");
		if(depthStep() < 0 || depthStep() > depthMax()) throw std::runtime_error("depth step should be in [0, maxDpth]");
		if(thickness() < depthMax()) throw std::runtime_error("thickness < max depth");
		if(totNumEl() < 1000) throw std::runtime_error("insufficient electron count");
		if(0 != resBytes1()[0] || 0 != resBytes1()[1]) throw std::runtime_error("reserved bytes must be 0");

		//sanity check diffraction components
		//tests for c1, c2, c3?
		if(numPx() < 3 || numPx() > 5000) throw std::runtime_error("diffraction grid size outside [3, 5000]");
		if(dMin() < 0.00001f || dMin() > 10.0f) throw std::runtime_error("unreasonable minimum d spacing");
		if(! (1 == latGridType() || 2 == latGridType() )) throw std::runtime_error("unknown lattitude grid type");
		for(size_t i = 0; i < 5; i++) if(0 != resBytes2()[i]) throw std::runtime_error("reserved bytes must be 0");
	}

	////////////////////////////////////////////////////////////////////////////////
	//                                  EMsoftXD                                  //
	////////////////////////////////////////////////////////////////////////////////

	//@brief  : check if this datatype supports a given modality
	//@param m: modality to check support for
	//@return : true if the data type supports m, false otherwise
	bool EMsoftXD::forModality(const Modality& m) const {
		switch(m) {
			case Modality::Laue: return true ;
			default            : return false;
		}
	}

	//@brief: byte swap data
	void EMsoftXD::byteSwap() {
		lambdaMin() = detail::byteSwap(lambdaMin());
		lambdaMax() = detail::byteSwap(lambdaMax());
		kappaVMF () = detail::byteSwap(kappaVMF ());
		intFactor() = detail::byteSwap(intFactor());
		numPx    () = detail::byteSwap(numPx    ());
	}

	void EMsoftXD::sanityCheck() const {
		if(lambdaMin() <= 0) throw std::runtime_error("non-positive wavelength is non-physical");
		if(lambdaMin() > lambdaMax()) throw std::runtime_error("minimum wavelength must be less than maximum wavelength");
		if(kappaVMF() < 0) throw std::runtime_error("negative von Mises kappa is non-physical");
		if(numPx() < 3 || numPx() > 5000) throw std::runtime_error("laue grid size outside [3, 5000]");
	}

	////////////////////////////////////////////////////////////////////////////////
	//                                    File                                    //
	////////////////////////////////////////////////////////////////////////////////

	//@brief: sanity check the contents of this data block (throw if not)
	void File::sanityCheck() const {
		//start by sanity checking pieces
		header.sanityCheck();
		mpData.sanityCheck();
		harmonics.sanityCheck();

		//check that everything is self consistent
		if(NULL != mpData.simul.front().get()) {
			if(!mpData.simul.front()->forModality(header.modality())) throw std::runtime_error("file modality doesn't match simulation modality");
		}
	}

	//@brief    : compute the CRC-32C hash of this data block
	//@param crc: initial hash value
	//@return   : new hash value
	uint32_t File::computeHash(uint32_t crc) const {
		crc = header.computeHash(crc);
		crc = mpData.computeHash(crc);
		crc = harmonics.computeHash(crc);
		return crc;
	}

	//@brief   : write data to an ostream
	//@param os: ostream to write to
	//@return  : os
	std::ostream& File::write(std::ostream& os) const {
		if(!os) throw std::runtime_error("sht::Files cannot write to invalid stream");
		sanityCheck();
		if(0 != os.tellp()) throw std::runtime_error("sht::Files must start at byte 0");
		const int32_t crc = computeHash(0x00000000);
		if(!header   .write(os)) throw std::runtime_error("failed to write sht header");
		if(!mpData   .write(os)) throw std::runtime_error("failed to write sht master pattern data");
		if(!harmonics.write(os)) throw std::runtime_error("failed to write sht harmonics");
		if(!os.write((char*)&crc, 4)) throw std::runtime_error("failed to write sht checksum"); 
		return os;
	}

	//@brief   : read data from an istream
	//@param is: istream to read from
	//@return  : is
	std::istream& File::read (std::istream& is) {
		//start by reading header
		if(!header.read(is)) throw std::runtime_error("failed to read sht header");
		const bool swp = header.endianMismatch();//is the file endedness different than the system?

		//read data blocks
		if(!mpData   .read(is, swp)) throw std::runtime_error("failed to read sht master pattern data");
		if(!harmonics.read(is, swp)) throw std::runtime_error("failed to read sht harmonics");
		if(!is.read((char*)&crcHash, 4)) throw std::runtime_error("failed to read sht checksum"); 

		//comppute checksum and compare to file
		const int32_t crc = computeHash(0x00000000);
		if(crc != crcHash) throw std::runtime_error("file corrupted (incorrect checksum)");

		//byteswap file if needed
		if(swp) {
			header.byteSwap();
			mpData.byteSwap();
			harmonics.byteSwap();
		}
		return is;
	}

	//@brief     : create an file without any master pattern data from EMsoft style data
	//@param iprm: integer parameters {sgn, mod, bw}
	//             sgn - effective space group number of spherical function
	//             mod - modality (see enumeration, EBSD == 1)
	//             bw  - bandwidth
	//@param fprm: float {keV, sig, tht, res} e.g. {20.0, 70.0, 0.0, 0.0} for typical EBSD
	//             keV - beam energy in keV
	//             sig - primary tilt angle
	//             tht - secondary tilt angle
	//             res - reserved parameter
	//@param doi : file DOI string (null terminated)
	//@param note: file level notes (null terminated)
	//@param alm : actual harmonics (uncompressed format)
	//@return    : error code (void return function throws instead)
	void File::initFileEMsoft   (int32_t const * iprm, float const * fprm, char const * doi, char const * note, double const * alm) {
		//build header
		header.modality      () = (Modality) iprm[1];
		header.beamEnergy    () =            fprm[0];
		header.primaryAngle  () =            fprm[1];
		header.secondaryAngle() =            fprm[2];
		header.reservedParam () =            fprm[3];
		header.setDoi  (doi );
		header.setNotes(note);

		//build master pattern data
		mpData.xtals.clear();
		mpData.simul.clear();
		mpData.numXtal() = 0;
		mpData.sgEff      () = (uint8_t ) iprm[0];
		mpData.pijk       () =            1      ;//EMsoft is always pijk +1
		mpData.rotSense   () =            112    ;//EMsoft is always passive
		mpData.modality   () = (Modality) iprm[1];
		mpData.vendor     () = Vendor::EMsoft    ;
		mpData.simMetaSize() = 0                 ;

		//build harmonics
		const int8_t  zFlg = HarmonicsData::SpaceGroupRot(iprm[0]);
		const int8_t  cFlg = HarmonicsData::SpaceGroupCmp(iprm[0]);
		const int32_t nHrm = HarmonicsData::NumHarm((int16_t) iprm[2], zFlg, cFlg);
		harmonics.bw     () = (int16_t) iprm[2];
		harmonics.zRot   () =           zFlg   ;
		harmonics.cmpFlg () =           cFlg   ;
		harmonics.doubCnt() = (int32_t) nHrm   ;
		harmonics.alm.resize(nHrm);
		harmonics.packHarm((std::complex<double>*)alm, harmonics.alm.data());
	}
	int  File::initFileEMsoftRet(int32_t const * iprm, float const * fprm, char const * doi, char const * note, double const * alm) {
		try {
			initFileEMsoft(iprm, fprm, doi, note, alm);
			return 0;
		} catch (std::exception& e) {
			std::cerr << e.what() << '\n';
			return 1;
		} catch (...) {
			std::cerr << "unknown error\n";
			return 2;
		}
	}

	//@brief     : add master pattern data to a file
	//@param iprm: integer paramters {sgn, sgs, nat, nel, elm, nsx, npx, grd}
	//       crystal data
	//             sgn - space group number
	//             sgs - space group setting
	//             nat - number of atoms
	//       simulation data
	//             nel - number of electrons
	//             elm - electron multiplier
	//             nsx - numsx (monte carlo grid size)
	//             npx - npx (master pattern grid size)
	//             grd - lattitude grid type
	//@param fprm: floating point parameters {a, b, c, alp, bet, gam, sgs, sge, sst, omg, kev, emn, esz, dmx, dmn, thk, c1, c2, c3, ddd, dmi}
	//       crystal data
	//             a   - lattice constant a in nm
	//             b   - lattice constant b in nm
	//             c   - lattice constant c in nm
	//             alp - lattice constant alpha in degrees
	//             bet - lattice constant beta  in degrees
	//             gam - lattice constant gamma in degrees
	//       simulation data
	//             sgs - sigma start
	//             sge - sigma end
	//             sst - sigma step
	//             omg - omega
	//             kev - keV
	//             emn - eHistMin
	//             esz - eBinSize
	//             dmx - depthMax
	//             dmn - depthMin
	//             thk - thickness
	//             c1  - c1
	//             c2  - c2
	//             c3  - c3
	//             ddd - sigDbDiff
	//             dmi - dMin
	//@param aTy : atom types (nAt atomic numbers)
	//@param aCd : atom coordinates (nAt * 5 floats {x, y, z, occupancy, Debye-Waller in nm^2})
	//@param vers: EMsoft version string (8 characters, null termination not required)
	//@param cprm: string parameters as one concatenated sequence will null seperators (+ final null terminator)
	//             {frm, nam, syb, ref}
	//             frm - formula string (null terimated)
	//             nam - material phase/name string (null terminated)
	//             syb - structure symbol string (null terminated)
	//             ref - reference string (null terminated)
	//             nte - note string (null terminated)
	//@return    : error code (void return function throws instead)
	void File::addDataEMsoft(int32_t const * iprm, float const * fprm, int32_t const * aTy, float const * aCd, char const * vers, char const * cprm) {
		//add new crystal structure
		mpData.xtals.resize(mpData.xtals.size() + 1);
		++mpData.numXtal();
		CrystalData& xtal = mpData.xtals.back();
		xtal.sgNum () = (uint8_t) iprm[0];
		xtal.sgSet () = (uint8_t) iprm[1];
		xtal.sgAxis() = CrystalData::Axis::Default;
		xtal.sgCell() = CrystalData::Cell::Default;
		xtal.oriX  () = 0.0f;
		xtal.oriY  () = 0.0f;
		xtal.oriZ  () = 0.0f;
		std::copy(fprm, fprm + 6, xtal.lat());
		xtal.rot()[0] = 1.0f; xtal.rot()[1] = 0.0f; xtal.rot()[2] = 0.0f; xtal.rot()[3] = 0.0f;
		xtal.weight() = 1.0f;
		xtal.numAtoms() = (int16_t) iprm[2];
		xtal.atoms.resize(iprm[2]);
		for(size_t i = 0; i < xtal.atoms.size(); i++) {
			//save atomic coordinates * 24
			for(size_t j = 0; j < 3; j++) {
				//start by bringing to [0,1]
				float x = aCd[5 * i + j];
				x = std::fmod(x, 1.0f);
				if(x < 0.0f) x += 1.0f;

				//next multiply by 24 handling 6ths specialy
				if     (1.0f / 6.0f == x) x  =  4.0f;
				else if(1.0f / 3.0f == x) x  =  8.0f;
				else if(2.0f / 3.0f == x) x  = 16.0f;
				else if(5.0f / 6.0f == x) x  = 20.0f;
				else                      x *= 24.0f;

				//save
				switch(j) {
					case 0: xtal.atoms[i].x() = x; break;
					case 1: xtal.atoms[i].y() = x; break;
					case 2: xtal.atoms[i].z() = x; break;
				}
			}

			//save other parameters
			xtal.atoms[i].occ   () = aCd[5*i+3];
			xtal.atoms[i].charge() = 0.0f      ;
			xtal.atoms[i].debWal() = aCd[5*i+4];
			xtal.atoms[i].atZ   () = aTy[  i  ];
		}
		char const * p = cprm;
		std::string form(p); p += form.size() + 1;
		std::string name(p); p += name.size() + 1;
		std::string symb(p); p += symb.size() + 1;
		std::string refs(p); p += refs.size() + 1;
		std::string note(p); p += note.size() + 1;
		xtal.setFormula(form);
		xtal.setName(name);
		xtal.setStructSym(symb);
		xtal.setRefs(refs);
		xtal.setNote(note);
	
		//add new simulation data
		std::unique_ptr<EMsoftED> ptr = std::unique_ptr<EMsoftED>(new EMsoftED);
		std::copy(vers, vers + 8, ptr->emsoftVersion());
		ptr->sigStart () = fprm[6+ 0];
		ptr->sigEnd   () = fprm[6+ 1];
		ptr->sigStep  () = fprm[6+ 2];
		ptr->omega    () = fprm[6+ 3];
		ptr->keV      () = fprm[6+ 4];
		ptr->eHistMin () = fprm[6+ 5];
		ptr->eBinSize () = fprm[6+ 6];
		ptr->depthMax () = fprm[6+ 7];
		ptr->depthStep() = fprm[6+ 8];
		ptr->thickness() = fprm[6+ 9];
		ptr->c1       () = fprm[6+10];
		ptr->c2       () = fprm[6+11];
		ptr->c3       () = fprm[6+12];
		ptr->sigDbDiff() = fprm[6+13];
		ptr->dMin     () = fprm[6+14];

		int64_t numEl = iprm[3+0];
		numEl *= iprm[3+1];
		ptr->totNumEl   () =           numEl  ;
		ptr->numSx      () = (int16_t) iprm[3+2];
		ptr->numPx      () = (int16_t) iprm[3+3];
		ptr->latGridType() = (int8_t ) iprm[3+4];

		if(!mpData.simul.empty()) {
			if(mpData.simul.back().get() == NULL) throw std::runtime_error("mixing null/non-null simulation data pointers");
			if(ptr->size() != mpData.simMetaSize()) throw std::runtime_error("mixing different size simulation data pointers");
		} else {
			mpData.simMetaSize() = (int16_t)ptr->size();//save size on first addition
		}
		mpData.simul.push_back(std::move(ptr));
	}
	int  File::addDataEMsoftRet(int32_t const  * iprm, float const  * fprm, int32_t const  * aTy, float const  * aCd, char const * vers, char const * cprm) {
		try {
			addDataEMsoft(iprm, fprm, aTy, aCd, vers, cprm);
			return 0;
		} catch (std::exception& e) {
			std::cerr << e.what() << '\n';
			return 1;
		} catch (...) {
			std::cerr << "unknown error\n";
			return 2;
		}
	}

}

#endif//_SHT_FILE_H_
