#ifndef SRC_OLEDCNTRL_H_ /* To avoid circular reference ---Check Later--- */
#define SRC_OLEDCNTRL_H_
/************************************************************************************/
/*Start Header*/

/* 
    Header Files included
*/
#include <xil_types.h> 

/* 
    This struct discribes my hardware.
*/
typedef struct OledCntrl{
    u32 BaseAddress;
}OledCntrl;
/* 
    Function to initialize the base address of the hardware,
    it takes two arguments a pointer to the hardware and its base address.
*/
int initOledCntrl(OledCntrl* MyOledCntrl, u32 BaseAddress);
/* 
    Function to write an 8-bit character,
    it takes two arguments a pointer to the hardware, and 
    an 8-bit character data and write it to the oled controller.
*/
void writeCharOled(OledCntrl* MyOledCntrl, char WriteData);
/* 
    Function to write an string,
    it takes two arguments a pointer to the hardware, and 
    a pointer to the string and write it to the oled controller.
*/
void writeOled(OledCntrl* MyOledCntrl, char* String);
/* 
    Function to clear "Turn OFF" the oled,
    it takes one arguments a pointer to the hardware,
    and write 0x0 to the oled controller.
*/
void clearOled(OledCntrl* MyOledCntrl);

/*End Header*/
/************************************************************************************/
#endif 