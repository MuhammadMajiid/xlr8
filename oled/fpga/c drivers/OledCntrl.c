/************************************************************************************/
/*Start Source*/


/* 
    Header Files included
*/
#include "OledCntrl.h"
#include <xil_io.h>
#include <xil_types.h>
#include <xparameters.h>

/* 
    Registers OFFESETS
*/
#define CNTRL_OFFSET 0
#define STATUS_OFFSET 4
#define DATA_OFFSET 8
#define OLED_CHAR_LENGTH 64

/* 
    Function to initialize the base address of the hardware,
    it takes two arguments a pointer to the hardware and its base address.
*/
int oledInit(OledCntrl* MyOledCntrl, u32 BaseAddress){
    MyOledCntrl->BaseAddress = BaseAddress;
    return 0;
}

/* 
    Function to write an 8-bit character,
    it takes two arguments a pointer to the hardware, and 
    an 8-bit character data and write it to the oled controller.
*/
void oledwriteChar(OledCntrl* MyOledCntrl, char WriteData, char DC_n){
    u32 status = 0;
    Xil_Out32(MyOledCntrl->BaseAddress+DATA_OFFSET, WriteData); // One Character is sent
    if (DC_n)
    {
        Xil_Out32(MyOledCntrl->BaseAddress+CNTRL_OFFSET,0x3);       // Valid is Set, dc_n is 1 *set to data*
    }
    else
    {
        Xil_Out32(MyOledCntrl->BaseAddress+CNTRL_OFFSET,0x1);       // Valid is Set, dc_n is 0 *set to command*
    }
    while (!status) {
        status = Xil_In32(MyOledCntrl->BaseAddress+STATUS_OFFSET); // Polling mode on Done signal *Use Interrupt later*
    }  
    Xil_Out32(MyOledCntrl->BaseAddress+STATUS_OFFSET,0x0); // Setting the done reg back to 0 for next transmission
}

/* 
    Function to write an string,
    it takes two arguments a pointer to the hardware, and 
    a pointer to the string and write it to the oled controller.
*/
void oledWrite(OledCntrl* MyOledCntrl, char* String){
    while(*String != 0){
        // The MyOledCntrl is of type pointer, so we passed it as it is to the writeChar
        // The second argument is a char, and we have a pointer String, to get the value pointed by the pointer
        // we put the * before the pointer.
        oledWriteChar(MyOledCntrl,*String, 0x1);
        // We increment the poitner itself to point to the next char
        String++;
    }
};

/* 
    Function to clear the oled
*/
void oledClear(OledCntrl* MyOledCntrl){
    u32 i;
    oledDefaultMode(MyOledCntrl);
    for (i=0; i<OLED_CHAR_LENGTH; i++){
        oledWriteChar(MyOledCntrl,0x0, 0x1);
    }
}
/* 
    Function to Set all ON
*/
void oledAllOn(OledCntrl *MyOledCntrl){
    oledWriteChar(MyOledCntrl,0xA5, 0x0);
}
/* 
    Function to Turn OFF the OLED
*/
void oledSleep(OledCntrl *MyOledCntrl){
    oledWriteChar(MyOledCntrl,0xAE, 0x0);
}
/* 
    Function to Turn ON the OLED
*/
void oledWakeUp(OledCntrl *MyOledCntrl){
    oledWriteChar(MyOledCntrl,0xAF, 0x0);
}
/* 
    Function to Inverse the Display >> 0 is ON / 1 is OFF
*/
void oledDisplayInverse(OledCntrl *MyOledCntrl){
    oledWriteChar(MyOledCntrl,0xA7, 0x0);
}
/* 
    Function to Set Normal Display Mode >> 1 is ON / 0 is OFF
*/
void oledDisplayNormal(OledCntrl *MyOledCntrl){
    oledWriteChar(MyOledCntrl,0xA6, 0x0);
}
/* 
    Function to Control Oled Contrast 0x00 to 0xFF, Default 0x7F
*/
void oledContrast(OledCntrl *MyOledCntrl, u8 ContrastVal){
    oledWriteChar(MyOledCntrl,0x81, 0x0);
    oledWriteChar(MyOledCntrl,ContrastVal, 0x0);
}
/* 
    Funtion to set Default Addressing Mode for the OLED with the default settings >> Horizontal
*/
void oledDefaultMode(OledCntrl *MyOledCntrl){
    oledWriteChar(MyOledCntrl,0x20, 0x0);
    oledWriteChar(MyOledCntrl,0x20, 0x0);
    oledWriteChar(MyOledCntrl,0x21, 0x0);
    oledWriteChar(MyOledCntrl,0x00, 0x0);
    oledWriteChar(MyOledCntrl,0x7F, 0x0);
    oledWriteChar(MyOledCntrl,0x22, 0x0);
    oledWriteChar(MyOledCntrl,0x00, 0x0);
    oledWriteChar(MyOledCntrl,0x03, 0x0);
}
/* 
    Funtions to set Addressing Mode for the OLED with user settings:
*/
void oledHorizontalMode(OledCntrl *MyOledCntrl, u8 StartColumn, u8 EndColumn, u8 StartPage, u8 EndPage){
    oledWriteChar(MyOledCntrl,0x20, 0x0);
    oledWriteChar(MyOledCntrl,0x20, 0x0);
    oledWriteChar(MyOledCntrl,0x21, 0x0);
    oledWriteChar(MyOledCntrl,StartColumn, 0x0);
    oledWriteChar(MyOledCntrl,EndColumn, 0x0);
    oledWriteChar(MyOledCntrl,0x22, 0x0);
    oledWriteChar(MyOledCntrl,StartPage, 0x0);
    oledWriteChar(MyOledCntrl,EndPage, 0x0);
}
void oledVerticalMode(OledCntrl *MyOledCntrl, u8 StartColumn, u8 EndColumn, u8 StartPage, u8 EndPage){
    oledWriteChar(MyOledCntrl,0x20, 0x0);
    oledWriteChar(MyOledCntrl,0x21, 0x0);
    oledWriteChar(MyOledCntrl,0x21, 0x0);
    oledWriteChar(MyOledCntrl,StartColumn, 0x0);
    oledWriteChar(MyOledCntrl,EndColumn, 0x0);
    oledWriteChar(MyOledCntrl,0x22, 0x0);
    oledWriteChar(MyOledCntrl,StartPage, 0x0);
    oledWriteChar(MyOledCntrl,EndPage, 0x0);
}
void oledPageMode(OledCntrl *MyOledCntrl, u8 LowCol, u8 HighCol, u8 StartPage){
    oledWriteChar(MyOledCntrl,0x20, 0x0);
    oledWriteChar(MyOledCntrl,0x22, 0x0);
    oledWriteChar(MyOledCntrl,LowCol, 0x0);
    oledWriteChar(MyOledCntrl,HighCol, 0x0);
    oledWriteChar(MyOledCntrl,0x22, 0x0);
    oledWriteChar(MyOledCntrl,StartPage, 0x0);
}
/* 
    Command No Operation
*/
void oledNOP(OledCntrl *MyOledCntrl){
    oledWriteChar(MyOledCntrl,0xE3, 0x0);
}

/************************************************************************************/

/* Carefull with using these functions */
/* Scrolling Commands */
void oledHorizontalScroll(OledCntrl *MyOledCntrl, u8 ScrollDir, u8 StartPg, u8 EndPg, u8 TimeStep){
    oledWriteChar(MyOledCntrl,ScrollDir, 0x0);
    oledWriteChar(MyOledCntrl,0x0, 0x0);
    oledWriteChar(MyOledCntrl,StartPg, 0x0);
    oledWriteChar(MyOledCntrl,TimeStep, 0x0);
    oledWriteChar(MyOledCntrl,EndPg, 0x0);
    oledWriteChar(MyOledCntrl,0x0, 0x0);
    oledWriteChar(MyOledCntrl,0xFF, 0x0);
}
void oledVerticalScroll(OledCntrl *MyOledCntrl, u8 ScrollDir, u8 StartPg, u8 EndPg, u8 TimeStep, u8 VerticalOffset){
    oledWriteChar(MyOledCntrl,ScrollDir, 0x0);
    oledWriteChar(MyOledCntrl,0x0, 0x0);
    oledWriteChar(MyOledCntrl,StartPg, 0x0);
    oledWriteChar(MyOledCntrl,TimeStep, 0x0);
    oledWriteChar(MyOledCntrl,EndPg, 0x0);
    oledWriteChar(MyOledCntrl,VerticalOffset, 0x0);
}
void oledDeactivateScroll(OledCntrl *MyOledCntrl){
    oledWriteChar(MyOledCntrl,0x2E, 0x0);
}
void oledActivateScroll(OledCntrl *MyOledCntrl){
    oledWriteChar(MyOledCntrl,0x2F, 0x0);
}
void oledVertScrollArea(OledCntrl *MyOledCntrl, u8 RowsA, u8 RowsB){
    oledWriteChar(MyOledCntrl,0xA3, 0x0);
    oledWriteChar(MyOledCntrl,RowsA, 0x0);
    oledWriteChar(MyOledCntrl,RowsB, 0x0);
}

/* Hardware Configuration Commands */
void oledStartLine(OledCntrl *MyOledCntrl, u8 Offset){
    oledWriteChar(MyOledCntrl,Offset, 0x0);
} // 0x40~0x7F
void oledSegReMap(OledCntrl *MyOledCntrl, u8 Offset){
    oledWriteChar(MyOledCntrl,Offset, 0x0);
}  // 0xA0/0xA1
void oledMuxRatio(OledCntrl *MyOledCntrl, u8 N){
    oledWriteChar(MyOledCntrl,0xA8, 0x0);
    oledWriteChar(MyOledCntrl,N, 0x0);
} // N[5:0]
void oledScanDir(OledCntrl *MyOledCntrl, u8 N){
    oledWriteChar(MyOledCntrl,N, 0x0);
} // 0xC0/0xC8
void oledDispOffset(OledCntrl *MyOledCntrl, u8 Offset){
    oledWriteChar(MyOledCntrl,0xD3, 0x0);
    oledWriteChar(MyOledCntrl,Offset, 0x0);
} // Offset[5:0]
void oledSetCom(OledCntrl *MyOledCntrl, u8 Offset){
    oledWriteChar(MyOledCntrl,0xDA, 0x0);
    oledWriteChar(MyOledCntrl,Offset, 0x0);
} // Offset[5:4]

/* Timing and Driving Commands */
void oledClkDiv(OledCntrl *MyOledCntrl, u8 Val){
    oledWriteChar(MyOledCntrl,0xD5, 0x0);
    oledWriteChar(MyOledCntrl,Val, 0x0);
}
void oledPreCharge(OledCntrl *MyOledCntrl, u8 Val){
    oledWriteChar(MyOledCntrl,0xD9, 0x0);
    oledWriteChar(MyOledCntrl,Val, 0x0);
}
void oledVCOM(OledCntrl *MyOledCntrl, u8 Val){
    oledWriteChar(MyOledCntrl,0xDB, 0x0);
    oledWriteChar(MyOledCntrl,Val, 0x0);
}

/*End Source*/
/************************************************************************************/