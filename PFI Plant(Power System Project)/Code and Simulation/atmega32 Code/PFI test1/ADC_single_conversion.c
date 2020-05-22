/*
 * ADC_single_conversion.c
 *
 * Created: 4/18/2015 12:55:23 PM
 *  Author: Shuvangkar Shuvo
 */ 
#include <avr/io.h>
#include "ADC_single_conversion.h"


void ADC_Initialize()
{
	ADCSRA |= 1<<ADEN; //ADC enable. ADC doesn't consume power when ADEN is cleared
	ADCSRA |=(1<<ADPS0)|(1<<ADPS1)|(1<<ADPS2); // prescaler=128 means X_cpu/128=7.8125KHz
	ADMUX |= 1<<REFS0; //Reference: AVCC (AVCC must be connected with VCC)
}

unsigned int ADC_Read(uint8_t channel)
{
	int adc_value = 0;
	//ADMUX |= (ADMUX&0b11100000)|(channel&0b00011111); // First five bits of ADMUX for selecting channel
	ADMUX = (ADMUX&0xf0)|(channel&0x0f);
	ADCSRA |=1<<ADSC; //Conversion will start writing this bit to one.
	while(!(ADCSRA&(1<<ADIF))); //ADIF will set when conversion complete and loop breaks.
	ADCSRA|= 1<<ADIF; //ADIF must be cleared(1) to trigger a new conversion next time
	adc_value = ADCW;
	return(adc_value);
	
}