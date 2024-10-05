/*
 * dmaSrc.c
 *
 *  Created on: Jun 12, 2024
 *      Author: majii
 */
/***************************** Include Files ********************************/
#include <xil_types.h>
#include <stdlib.h>
#include <xuartps.h>
#include <xparameters.h>
#include <xil_printf.h>
#include <xaxidma.h>
#include <sleep.h>
#include "xil_cache.h"
/************************** Constant Definitions ****************************/
#define imageSize (512*512)
#define headerSize 1080
#define fileSize (imageSize + headerSize)
/************************** Function Definitions ****************************/
u32 dmaCheckHalted(u32 BaseAddr, u32 offset);
/************************** Main ****************************/
int main(){

	u8* imageData;
	imageData = (u8*) malloc(sizeof(u8) * fileSize);
    if(imageData <= 0){
        xil_printf("Memory Allocation Failed\n");
        return -1;
    }
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

	XAxiDma_Config *dmaConifg;
	XAxiDma dma;

	dmaConifg = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
	status = XAxiDma_CfgInitialize(&dma, dmaConifg);
	if(status  != XST_SUCCESS){
		print("DMA Init Failed\n");
		return -1;
	}
	print("DMA Init Success\n");

    //	Receive data to DDR
	u32 totalRXBytes=0;
	u32 recBytes=0;
	while (totalRXBytes < fileSize){
		recBytes = XUartPs_Recv(&uartInst,(u8*)&imageData[totalRXBytes],100);
		totalRXBytes += recBytes;
	}

	status = dmaCheckHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
	xil_printf("Status before Data Trans is %0x \n", status);

    Xil_DCacheFlush();

    //	Read Data from DDR to Process it
    status = XAxiDma_SimpleTransfer(&dma, (u32)&imageData[headerSize], imageSize, XAXIDMA_DEVICE_TO_DMA);
	if(status  != XST_SUCCESS){
				print("DMA Rx Config Failed\n");
				return -1;
			}
	print("DMA Rx Config Success\n");

	status = XAxiDma_SimpleTransfer(&dma, (u32)&imageData[headerSize], imageSize, XAXIDMA_DMA_TO_DEVICE);
	if(status  != XST_SUCCESS){
			print("DMA Tx Config Failed\n");
			return -1;
		}
	print("DMA Tx Config Success\n");

//	sleep(1); // 1s delay

	status = dmaCheckHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
	while(status != 1){
		status = dmaCheckHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
	}
	xil_printf("Status after Data Trans is %0x \n", status);
	status = dmaCheckHalted(XPAR_AXI_DMA_0_BASEADDR, 0x34);
		while(status != 1){
			status = dmaCheckHalted(XPAR_AXI_DMA_0_BASEADDR, 0x34);
		}
	xil_printf("Status after Data Trans received is %0x \n", status);
	xil_printf("DMA Transmission Success.\n");

    //	Send data from DDR to PC
	u32 totalTXBytes=0;
	u32 transBytes=0;
	while (totalTXBytes < fileSize){
		transBytes = XUartPs_Send(&uartInst,(u8*)&imageData[totalTXBytes], 1);
		totalTXBytes += transBytes;
		usleep(2000);
	}

}

u32 dmaCheckHalted(u32 BaseAddr, u32 offset){
	u32 status;
	status = XAxiDma_ReadReg(BaseAddr, offset) & XAXIDMA_HALTED_MASK;
	return status;
}
