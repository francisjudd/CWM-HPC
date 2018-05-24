/**************************************************
 *                                                *
 * First attempt at a code to calcule lost barley *
 * by A. Farmer                                   *
 * 18/05/18                                       *
 *                                                *
 **************************************************/

// Include any headers from the C standard library here
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Define any constants that I need to use here
#define PI 3.1415927

// This is where I should put my function prototypes
float area_of_circle(float radius); 
float area_of_annulus(float radius1, float radius2);

// Now I start my code with main()
int main() {

    // In here I need to delare my variables
	int i=0, num_circles=0, type_flag=0;
	char ch;
	float *radii, *area;
	float total_area=0, loss_in_kg=0;
	
    // Next I need to get input from the user.
    // I'll do this by using a printf() to ask the user to input the radii.
	FILE *fp;
        char filename[200], *mode;
	printf("\nEnter your file: ");
	scanf("%s",filename);
	//printf("\nEnter a file mode: ");
	//scanf("%s",mode);
	mode = "r";
	printf("\n1 for circles or 2 for rings: ");
	scanf("%d",&type_flag);

    //Prevent null exception for empty file
	if( (fp=fopen( filename, mode )) == NULL ) {
		exit(1);
	}
	fp = fopen(filename,mode);

    //Count number of circles
	while((ch = fgetc(fp)) != EOF) {
		if (ch == '\n') { 
			++num_circles; 
		}
	}

    //Initialise radii array to be same length as input length
	radii = (float *)malloc(num_circles*sizeof(float));
	area = (float *)malloc(num_circles*sizeof(float));

    //Reset pointer to beginning of file
	fclose(fp);
	fp=fopen(filename, mode);

    //Retreive radii	
	for( i = 0; i < num_circles; i++) {
		fscanf(fp, "%f", &radii[i]);
	}

    // Now I need to loop through the radii caluclating the area for each and add to total
	for( i = 0; i < num_circles; i++) {
		area[i] = area_of_circle(radii[i]);
	        total_area += area[i];
	}	

    // Determine whether data is for circles or rings
	switch( type_flag ) {
		default:
			break;
		case 1:
			break;
		case 2:
			if( num_circles % 2 == 1 ) {
				total_area = 0;
				for( i = 0; i < (num_circles - 1); i += 2 ) {
					total_area += fabs( area[i] - area[i+1] );
				}
				//i += 2;
				total_area += area[i];
			}
			break;
	}

    // One square meter of crop produces about 135 grams of barley.
    // One kg of barley sells for about 10 pence.

    // Work out how much barley has been lost.
	loss_in_kg = total_area*0.135;

    // Print this result to the screen.
	printf("\nTotal area lossed in m^2 is:\t%f\n", total_area);
	printf("Total loss in kg is:\t\t%f\n", loss_in_kg);

	return(0);
}

// I'll put my functions here:

float area_of_circle(float radius) {
	float area = PI * radius * radius;
	return area;
}

float area_of_annulus(float radius1, float radius2) {
	float area = fabs(PI * ((radius1 * radius1) - (radius2 * radius2)));
	return area;
}
