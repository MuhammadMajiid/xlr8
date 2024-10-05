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
    Constants
*/
#define CNTRL_OFFSET 0
#define STATUS_OFFSET 4
#define DATA_OFFSET 8
#define OLED_CHAR_LENGTH 64

/* 
    Function to initialize the base address of the hardware,
    it takes two arguments a pointer to the hardware and its base address.
*/
int initOledCntrl(OledCntrl* MyOledCntrl, u32 BaseAddress){
    MyOledCntrl->BaseAddress = BaseAddress;
    return 0;
}

/* 
    Function to write an 8-bit character,
    it takes two arguments a pointer to the hardware, and 
    an 8-bit character data and write it to the oled controller.
*/
void writeCharOled(OledCntrl* MyOledCntrl, char WriteData){
    u32 status = 0;
    Xil_Out32(MyOledCntrl->BaseAddress+DATA_OFFSET, WriteData); // One Character is sent
    Xil_Out32(MyOledCntrl->BaseAddress+CNTRL_OFFSET,0x1);       // Valid is Set
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
void writeOled(OledCntrl* MyOledCntrl, char* String){
    while(*String != 0){
        // The MyOledCntrl is of type pointer, so we passed it as it is to the writeChar
        // The second argument is a char, and we have a pointer String, to get the value pointed by the pointer
        // we put the * before the pointer.
        writeCharOled(MyOledCntrl,*String);
        // We increment the poitner itself to point to the next char
        String++;
    }
};

/* 
    Function to clear "Turn OFF" the oled,
    it takes one arguments a pointer to the hardware,
    and write 0x0 to the oled controller.
*/
void clearOled(OledCntrl* MyOledCntrl){
    u32 i;
    for (i=0; i<OLED_CHAR_LENGTH; i++){
        writeCharOled(MyOledCntrl,0x0);
    }
}

/*End Source*/
/************************************************************************************/