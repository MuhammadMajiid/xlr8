/*
 * dmaSrc.c
 *
 *  Created on: Jun 12, 2024
 *      Author: majii
 */

#include <xaxidma.h>
#include <xparameters.h>
#include <xil_types.h>
#include <xil_printf.h>
#include <sleep.h>
#include "xil_cache.h"

u32 dmaCheckHalted(u32 BaseAddr, u32 offset);

int main(){

	u32 i[] = {0,1,2,3,4,5,6,7,8,9};
	u32 j[10];
	u32 arr_len = sizeof(i);
	u32 status;

	XAxiDma_Config *dmaConifg;
	XAxiDma dma;

	dmaConifg = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
	status = XAxiDma_CfgInitialize(&dma, dmaConifg);
	if(status  != XST_SUCCESS){
		print("DMA Init Failed\n");
		return -1;
	}
	print("DMA Init Success\n");

	status = dmaCheckHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
	xil_printf("Status before Data Trans is %0x \n", status);

	Xil_DCacheFlushRange((u32)i, arr_len);

	status = XAxiDma_SimpleTransfer(&dma, (u32)j, arr_len, XAXIDMA_DEVICE_TO_DMA);
	if(status  != XST_SUCCESS){
				print("DMA Rx Config Failed\n");
				return -1;
			}
	print("DMA Rx Config Success\n");

	status = XAxiDma_SimpleTransfer(&dma, (u32)i, arr_len, XAXIDMA_DMA_TO_DEVICE);
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

	for(int n=0; n<(sizeof(i)/sizeof(32)); n++){
		xil_printf("%0x\n", i[n]);
		xil_printf("%0x\n", j[n]);
	}
}

u32 dmaCheckHalted(u32 BaseAddr, u32 offset){
	u32 status;
	status = XAxiDma_ReadReg(BaseAddr, offset) & XAXIDMA_HALTED_MASK;
	return status;
}
