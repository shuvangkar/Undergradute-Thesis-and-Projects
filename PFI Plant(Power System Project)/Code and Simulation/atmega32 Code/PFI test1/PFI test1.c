/*
 * PFI_test1.c
 *
 * Created: 4/21/2015 9:02:08 PM
 *  Author: Shuvangkar Shuvo
 */ 


#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <math.h>
#include "ADC_single_conversion.h"
#include "usart.h"
#define current_pin 1
#define volt_pin 0
#define number_of_samples 200
#define sample_delay 700
#define F_CPU 16000000

int voltage_adc[number_of_samples]={0},current_adc[number_of_samples]={0},index_volt=0,index_current=0;;
uint8_t i=0,j=0,k=0,l=0,n=0;
volatile unsigned int volt_peak_time1 =0,volt_peak_time2=0,current_peak_time1=0,current_peak_time2=0;
int volt_peak1=0,volt_peak2=0,current_peak=0,current_peak2=0,temp=0,temp1=0;
int tolerance_volt=0,tolerance_current=0,tolerance_pf=0;
double power_factor=0,power_factor_2=0;
double average_volt=0,average_current=0,actual_volt=0,actual_current=0,Vrms=0,Irms=0,V_avg=0,I_avg=0,volt_square_sum=0,current_squared_sum=0,real_power=0;

int main(void)
{
	setup();
    while(1)
    {
		//print_voltage_current();
		calculate_power_factor();
		ADCSRA |=(1<<ADEN);
		TCNT1 = 0;
		index_volt = voltage_zero_cross_time();
		index_current = current_zero_cross_time();
		ADCSRA &= ~(1<<ADEN);
		_delay_ms(30000);
		ADCSRA |=(1<<ADEN);
	
    }
}

void setup()
{
		Initialize_INT0();
		ADC_Initialize();
		Init_timer1_normal_mode_with_overflow();
		USARTInit(25);
		DDRB |=1<<PB0;
		_delay_ms(10);
}
ISR(INT0_vect)
{
	
	//PORTB ^=1<<PB0;
}

ISR(TIMER1_OVF_vect)
{
	
		PORTB ^=1<<PB0;

}


void voltage_current_read()
{
	
	for (i=0;i<number_of_samples;i++)
	{
		voltage_adc[i]=ADC_Read(volt_pin);
		//_delay_us(700);;
		current_adc[i]= ADC_Read(current_pin);
		//_delay_us(700);
	}
}
void print_voltage_current()
{
	UWriteString("\n voltage \n");
	for (i=0;i<number_of_samples;i++)
	{
		print_integer(voltage_adc[i]);
		UWriteString("\t");
	}
	UWriteString("\n Current \n");
	for (i=0;i<number_of_samples;i++)
	{
		print_integer(current_adc[i]);
		UWriteString("\t");
	}
}

Init_timer1_normal_mode_with_overflow()
{
	TCCR1B |=(1<<CS10)|(1<<CS11); //timer 1 is activated with prescaler 64
	TIMSK |= 1<<TOIE1; //Overflow interrupt enalbe, so when timer reaches its maximum value, it overflows and overflow interrupt vector routine will be executed
	sei(); // enable global interrupt
}
Initialize_INT0()
{
	sei(); //enable global interrupt
	GICR |=1<<INT0;  //External interrupt on INT0 pin is enabled
	//MCUCR &= (~(1<<ISC00))&(~(1<<ISC01)); //the low level on INTo generates an interrupt
	MCUCR |= 1<<ISC00; //any logic change on INT0 pin generates an interrupt request
	//MCUCR |=1<<ISC01; //The falling edge(high to low) of INT0 generates an interrupt request.
}


int find_voltage_peak()
{
	temp=ADC_Read(volt_pin);
	_delay_us(sample_delay);
	if(temp < volt_peak1) //Max value found
	{
		return(1);
	}
	else
	{
		volt_peak1 = temp;
		return(0);
	}
}
int find_voltage_peak2()
{
	temp=ADC_Read(volt_pin);
	_delay_us(sample_delay);
	if(temp < volt_peak2) //Max value found
	{
		return(1);
	}
	else
	{
		volt_peak2 = temp;
		return(0);
	}
}
int find_current_peak()
{
	temp1=ADC_Read(current_pin);
	_delay_us(sample_delay);
	if(temp1 < current_peak) //Max value found
	{
		return(1);
	}
	else
	{
		current_peak = temp1;
		return(0);
	}
}
int find_current_peak2()
{
	temp1=ADC_Read(current_pin);
	_delay_us(sample_delay);
	if(temp1 < current_peak2) //Max value found
	{
		return(1);
	}
	else
	{
		current_peak2 = temp1;
		return(0);
	}
}

void calculate_power_factor()
{
	voltage_current_read();
	ADCSRA &= ~(1<<ADEN);
	//print_voltage_current();
	//Average voltage and current calculation
	for (n=0;n<number_of_samples;n++)
	{
		average_volt += (5.00*voltage_adc[n])/1024.00;
		average_current += (5.00*current_adc[n])/1024.00;
		
	}
	average_volt = average_volt/number_of_samples;
	average_current = average_current/number_of_samples;
	//UWriteString(" \n Average voltage = ");
	//print_double(average_volt,4,3);
	//UWriteString(" \n Average current = ");
	//print_double(average_current,4,3);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
//	UWriteString(" \n Actual voltage \n");
	volt_square_sum = 0;
	current_squared_sum=0;
	V_avg=0;
	for (n=0;n<number_of_samples;n++)
	{
		actual_volt = ((5.00*voltage_adc[n])/1024.00)-average_volt;
		V_avg = V_avg+actual_volt;
		volt_square_sum = volt_square_sum+pow(actual_volt,2);
		//print_double(actual_volt,4,3);
	   //UWriteString("\t");
		//actual_current = ((5.00*current_adc[n])/1024.00)-average_current;
		
	}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//UWriteString(" \n Actual current \n");
	I_avg=0;
	for (n=0;n<number_of_samples;n++)
	{
		actual_current = ((5.00*current_adc[n])/1024.00)-average_current;
		I_avg=I_avg+actual_current;
		current_squared_sum = current_squared_sum+pow(actual_current,2);
		//print_double(actual_current,4,3);
		//UWriteString("\t");
		
		
	}
	
	Vrms = volt_square_sum/number_of_samples;
	Vrms=sqrt(Vrms);
	//Vrms = 511.00/11*Vrms;
	Irms = current_squared_sum/number_of_samples;
	Irms=sqrt(Irms);
	//Irms = Irms/2.2;
	
	
	//Instantaneous power and real power
	real_power = 0;
	for (n=0;n<number_of_samples;n++)
	{
		actual_volt = ((5.00*voltage_adc[n])/1024.00)-average_volt;
		//actual_volt = actual_volt*511.00/11;
		actual_current = ((5.00*current_adc[n])/1024.00)-average_current;
		//actual_current = actual_current/2.2;
		real_power = real_power+(actual_volt*actual_current);
		
	}
	real_power = real_power/number_of_samples;
	power_factor = real_power/(Vrms*Irms);
	UWriteString("\n Vrms = ");
	print_double(Vrms,4,3);
	UWriteString("V");
	UWriteString("\tIrms = ");
	Irms=Irms*1000;
	print_double(Irms,4,3);
	UWriteString("mA");
	UWriteString("\tPower = ");
	print_double(real_power, 3,5);
	UWriteString("W");
	UWriteString("\tPower factor = ");
	print_double(power_factor,4,3);
	

	
}

int voltage_zero_cross_time()
{
	int index = 0;
	actual_volt = ((5.00*voltage_adc[0])/1024.00)-average_volt;
	if (actual_volt>0)
	{
		for (i=1;i<number_of_samples;i++)
		{
			actual_volt = ((5.00*voltage_adc[i])/1024.00)-average_volt;
			if (actual_volt<0)
			{
				return(i);
				//index = i;
				i=number_of_samples;
			
			}
			
		}
	}
	else
	{
		for (i=1;i<number_of_samples;i++)
		{
			actual_volt = ((5.00*voltage_adc[i])/1024.00)-average_volt;
			if (actual_volt>0)
			{
				return(i);
				//index = i;
				i=number_of_samples;
				
			}
			
		}
		
	}
	//return(index);
}

int current_zero_cross_time()
{
	int index = 0;
	actual_current = ((5.00*current_adc[0])/1024.00)-average_current;
	if (actual_current>0)
	{
		for (i=1;i<number_of_samples;i++)
		{
			actual_current = ((5.00*current_adc[i])/1024.00)-average_current;
			if (actual_current<0)
			{
				return(i);
				//index = i;
				i=number_of_samples;
				
			}
			
		}
	}
	else
	{
		for (i=1;i<number_of_samples;i++)
		{
			actual_current = ((5.00*current_adc[i])/1024.00)-average_current;
			if (average_current>0)
			{
				return(i);
				//index = i;
				i=number_of_samples;
				
			}
			
		}
		
	}
	//return(index);
}

