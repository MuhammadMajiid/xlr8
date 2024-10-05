#ifndef SRC_OLEDCNTRL_H_ /* To avoid circular reference ---Check--- */
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
int oledInit(OledCntrl* MyOledCntrl, u32 BaseAddress);
/* 
    Function to write an 8-bit character,
    it takes two arguments a pointer to the hardware, and 
    an 8-bit character data and write it to the oled controller.
*/
void oledWriteChar(OledCntrl* MyOledCntrl, char WriteData, char DC_n);
/* 
    Function to write an string,
    it takes two arguments a pointer to the hardware, and 
    a pointer to the string and write it to the oled controller.
*/
void oledWrite(OledCntrl* MyOledCntrl, char* String);
/* 
    Function to clear the oled
*/
void oledclear(OledCntrl* MyOledCntrl);
/* 
    Function to Set all ON
*/
void oledAllOn(OledCntrl *MyOledCntrl);
/* 
    Function to Turn OFF the OLED
*/
void oledSleep(OledCntrl *MyOledCntrl);
/* 
    Function to Turn ON the OLED
*/
void oledWakeUp(OledCntrl *MyOledCntrl);
/* 
    Function to Inverse the Display >> 0 is ON / 1 is OFF
*/
void oledDisplayInverse(OledCntrl *MyOledCntrl);
/* 
    Function to Set Normal Display Mode >> 1 is ON / 0 is OFF
*/
void oledDisplayNormal(OledCntrl *MyOledCntrl);
/* 
    Function to Control Oled Contrast 0x00 to 0xFF, Default 0x7F
*/
void oledContrast(OledCntrl *MyOledCntrl, u8 ContrastVal);
/* 
    Command No Operation
*/
void oledNOP(OledCntrl *MyOledCntrl);

/* 
    Funtion to set Default Addressing Mode for the OLED with the default settings >> Horizontal
*/
void oledDefaultMode(OledCntrl *MyOledCntrl);

/* 
    Addressing Modes
*/
void oledHorizontalMode(OledCntrl *MyOledCntrl, u8 StartColumn, u8 EndColumn, u8 StartPage, u8 EndPage);
void oledVerticalMode(OledCntrl *MyOledCntrl, u8 StartColumn, u8 EndColumn, u8 StartPage, u8 EndPage);
void oledPageMode(OledCntrl *MyOledCntrl, u8 LowCol, u8 HighCol, u8 StartPage);

/************************************************************************************/

/* Carefull with using these functions */
/* Scrolling Commands */
void oledHorizontalScroll(OledCntrl *MyOledCntrl, u8 ScrollDir, u8 StartPg, u8 EndPg, u8 TimeStep);
void oledVerticalScroll(OledCntrl *MyOledCntrl, u8 ScrollDir, u8 StartPg, u8 EndPg, u8 TimeStep, u8 VerticalOffset);
void oledDeactivateScroll(OledCntrl *MyOledCntrl);
void oledActivateScroll(OledCntrl *MyOledCntrl);
void oledVertScrollArea(OledCntrl *MyOledCntrl, u8 RowsA, u8 RowsB);
/* Hardware Configuration Commands */
void oledStartLine(OledCntrl *MyOledCntrl, u8 Offset); // 0x40~0x7F
void oledSegReMap(OledCntrl *MyOledCntrl, u8 Offset);  // 0xA0/0xA1
void oledMuxRatio(OledCntrl *MyOledCntrl, u8 N);
void oledScanDir(OledCntrl *MyOledCntrl, u8 N);        // 0xC0/0xC8
void oledDispOffset(OledCntrl *MyOledCntrl, u8 Offset);
void oledSetCom(OledCntrl *MyOledCntrl, u8 Offset);
/* Timing and Driving Commands */
void oledClkDiv(OledCntrl *MyOledCntrl, u8 Val);
void oledPreCharge(OledCntrl *MyOledCntrl, u8 Val);
void oledVCOM(OledCntrl *MyOledCntrl, u8 Val);

/*End Header*/
/************************************************************************************/
#endif 