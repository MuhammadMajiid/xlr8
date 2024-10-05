#include "OledCntrl.h"
#include <xparameters.h>
#include <xil_printf.h>

int main(){
    char* string = "Hello World!";
    OledCntrl my_oled;
    initOledCntrl(&my_oled, XPAR_OLEDCONTROLLER_0_BASEADDR);
    clearOled(&my_oled);
    writeOled(&my_oled, string);
    return 0;
}