/* This is with the predefined ZedBoard platform */
/***************************** Include Files ********************************/
#include <xil_types.h>
#include <stdlib.h>
#include <xuartps.h>
#include <xparameters.h>
#include <sleep.h>
#include <xil_printf.h>

/************************** Constant Definitions ****************************/
#define imageSize (512*512)
#define headerSize 1080
#define fileSize (imageSize + headerSize)

int main(){
	u8* imageData;
	imageData = (u8*) malloc(sizeof(u8) * fileSize);
    if(imageData <= 0){
        xil_printf("Memory Allocation Failed\n");
        return -1;
    }

//	Storing Data through UART
//	for(int i=0;i<fileSize;i++){
//		scanf("%c", &imageData[i]);
//	} 
/*UART driver is embedded in scanf, still Not the Best Solution though*/
	XUartPs_Config* uartConfig;
	uartConfig = XUartPs_LookupConfig(XPAR_PS7_UART_1_DEVICE_ID);
	XUartPs uartInst;
	u32 status;
	status = XUartPs_CfgInitialize(&uartInst, uartConfig, uartConfig->BaseAddress);
	if (status !=XST_SUCCESS){
		print("UART Init Failed..\n");
	}
	status = XUartPs_SetBaudRate(&uartInst, 115200);
	if (status !=XST_SUCCESS){
			print("UART BR Failed..\n");
		}
//	Receive data to DDR
	u32 totalRXBytes=0;
	u32 recBytes=0;
	while (totalRXBytes < fileSize){
		recBytes = XUartPs_Recv(&uartInst,(u8*)&imageData[totalRXBytes],100);
		totalRXBytes += recBytes;
	}
// To Check whether it recieves data correctly
	for (int i=0; i<10; i++){
		xil_printf("%0x", imageData[i]);
	}
//	Read Data from DDR to Process it
	for (int i = headerSize; i<fileSize; i++){
		imageData[i] = 255 - imageData[i];
	}
//	Send data from DDR to PC
	u32 totalTXBytes=0;
	u32 transBytes=0;
	while (totalTXBytes < fileSize){
		transBytes = XUartPs_Send(&uartInst,(u8*)&imageData[totalTXBytes], 1);
		totalTXBytes += transBytes;
        usleep(2000);
	}

}
