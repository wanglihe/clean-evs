/*====================================================================================
    EVS Codec 3GPP TS26.443 Aug 30, 2016. Version 12.7.0 / 13.3.0
  ====================================================================================*/

/*
  ===========================================================================
   File: TYPEDEF.H                                       v.2.3 - 30.Nov.2009
  ===========================================================================

            ITU-T STL  BASIC OPERATORS

            TYPE DEFINITION PROTOTYPES

   History:
   26.Jan.00   v1.0     Incorporated to the STL from updated G.723.1/G.729
                        basic operator library (based on basic_op.h)

   03 Nov 04   v2.0     Incorporation of new 32-bit / 40-bit / control
                        operators for the ITU-T Standard Tool Library as
                        described in Geneva, 20-30 January 2004 WP 3/16 Q10/16
                        TD 11 document and subsequent discussions on the
                        wp3audio@yahoogroups.com email reflector.
   March 06   v2.1      Changed to improve portability.

  ============================================================================
*/

/*_____________________
 |                     |
 | Basic types.        |
 |_____________________|
*/

#include "options.h"

#ifndef TYPEDEF_H
#define TYPEDEF_H

#include <stdint.h>

typedef int8_t Word8;
typedef uint8_t UWord8;
typedef int16_t Word16;
typedef int32_t Word32;
typedef uint16_t UWord16;
typedef uint32_t UWord32;
typedef int64_t Word40;
typedef int32_t Flag;

typedef float Float32;

#endif /* ifndef _TYPEDEF_H */


/* end of file */
