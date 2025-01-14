extern void MOTEUR_DROIT_ON();
extern void MOTEUR_GAUCHE_ON();
extern void MOTEUR_DROIT_OFF();
extern void MOTEUR_GAUCHE_OFF();
extern void MOTEUR_DROIT_AVANT();
extern void MOTEUR_DROIT_ARRIERE();
extern void MOTEUR_GAUCHE_AVANT();
extern void MOTEUR_GAUCHE_ARRIERE();
extern int length_steps;

#include <stdlib.h>
#define PWM0CMPA 0x058
#define PWM1CMPA 0x098

#define qei_position_0 (int*) 0x4002C008
#define qei_position_1 (int*) 0x4002D008
#define desired_position 0x2F6
#define default_multiplier 3

typedef struct {
	int position_right;
	int position_left;
	int speed_right;
	int speed_left;
} Pve;


extern Pve steps;

Pve* Commands;
int len_commands;

int desired_position_right;
int desired_position_left;

int speed_left;
int speed_right;

int current_command;

unsigned short limit_error(int error, int multiplier, unsigned short min, unsigned short range);
int limit_speed(int speed, int max_speed);

void init_globals(){
	Commands = &steps;
	speed_left = 0;
	speed_right = 0;
	len_commands = length_steps;
	desired_position_right= 0;
	desired_position_left= 0;
	current_command= -1;
}
	

int main_loop(){
	//MOTEUR_DROIT_ON();
	//MOTEUR_GAUCHE_ON();
	int left_finished = 0;
	int right_finished = 0;
	
	int position_0 = *qei_position_0;
	int position_1 = *qei_position_1;
	
	int error_0 = desired_position_right - position_0; // right qei0
	int error_1 = desired_position_left - position_1;
	
	unsigned short pwm_error_0 = limit_error(error_0, default_multiplier, 0x190, limit_speed(speed_right, 0x12C)); 
	unsigned short pwm_error_1 = limit_error(error_1, default_multiplier, 0x190+12, limit_speed(speed_left, 0x12C));// max of the right is bigger than left
	
	// doesnt work outside the func
	volatile unsigned int  *pwm_0 = (unsigned int *)0x040028058LU;
	volatile unsigned int  *pwm_1 = (unsigned int*)0x040028098LU;
	
	*pwm_0= pwm_error_0;
	*pwm_1= pwm_error_1;
	

	if (error_0>0){
		MOTEUR_DROIT_ON();
		MOTEUR_DROIT_AVANT();
	}
	else if (error_0<0) {
		MOTEUR_DROIT_ON();
		MOTEUR_DROIT_ARRIERE();
	}
	else {
		MOTEUR_DROIT_OFF();
		right_finished = 1;
	}
	
	if (error_1>0){
		MOTEUR_GAUCHE_ON();
		MOTEUR_GAUCHE_AVANT();
	}
	else if (error_1<0) {
		MOTEUR_GAUCHE_ON();
		MOTEUR_GAUCHE_ARRIERE();
	}
	else {
		MOTEUR_GAUCHE_OFF();
		left_finished = 1;
	}
	//int position_right;
	//int position_left;
	
	if (left_finished && right_finished){
		if (current_command + 1 < len_commands){
			current_command += 1;
			//position_right = Commands[current_command].position_right;
			//position_left = Commands[current_command].position_left;
			desired_position_right += Commands[current_command].position_right;
			desired_position_left += Commands[current_command].position_left;
			speed_left = Commands[current_command].speed_left;
			speed_right = Commands[current_command].speed_right;
		}
		else return 1;
		
	}
	return 0;
}

unsigned short limit_error(int error, int multiplier, unsigned short min, unsigned short range){
	error = abs(error*multiplier);
	int min_pwm = 0xFFFF - min;
	int max_pwm = min + range;
	if (error>range){
		error = range;
	}
	else if (error<0) {
		error=0;
	}
	error += min_pwm;
	error = 0xFFFF - error;
	return error;
}

int limit_speed(int speed, int max_speed){
	if (speed>max_speed) return max_speed;
	if (speed<0) return 0;
	return speed;
}
