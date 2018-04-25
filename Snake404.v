module Snake404
(
input [1:0] KEY , // keys
input clockInp, // clock
output reg [47:0] HEX // displays
);


//Turn off all HEX's

initial
begin
    HEX = 48'hFFFFFFFFFFFF;
end

integer clockInp_count = 0; //Number of clock cycles
reg move_clk; //Indicator for snake's movements
integer delay = 20; //Define delay between snake's movements


//Generate new clock signal for snake's movements

always @(posedge clockInp)
begin
    clockInp_count= clockInp_count + 1;

    if (clockInp_count >= (20000*delay))
    begin
        clockInp_count = 0;
        move_clk = ~move_clk;
    end

end

//Variables which define form of snake

integer Queue[0:30]; //Queue for number of snake's positions
integer head = 0; //Position of snake's head
integer length = 1; //Length of snake

//Variables which define current direction

reg direction = 0; //Define horizontal(0) or vertical(1) direction of snake
reg horizontal = 0; //Define right(0) or left(1) direction
reg vertical = 0; //Define down(0) or up(1) direction

integer delta = 0; //Difference between current and next position
integer current_position = 0; //Nuber of current position modulo 8

//Variables which used to check conditions of loosing game

integer turn_right = 0;//Delta for moving right
integer turn_left = 0;//Delta for moving left

reg total_cross = 0; //Indicator of crossing

//Two indicators which check crossing body of snake

reg cross_turn_right = 0;
reg cross_turn_left = 0;

reg cross_tail = 0; //Indicator of crossing snake's tail

//Variables which indicate ending of game and time for showing message

reg end_game = 0;
integer end_game_delay = 20;

//Variables for "apples"

integer apple_pos = 0; //Position of "apple"
integer apple_blink = 0; //Define the frequecy of blinking "apple"

//Extra variable for loop

integer i;

//Main logic of game

always @(negedge move_clk)
begin

	//At the beginning check result of previous movement (lose or win game of presious step)
	
    if(end_game)
    begin
	 
		  //If we end game, generate delay for showing message (it will be visiable for human eyes for a few seconds)
		  
        if(end_game_delay <= 0) //While we have non-zero delay, we will see message
        begin
            HEX = 48'hFFFFFFFFFFFF; //Clean the display from message
            end_game = 0; //Reset the signal of ending hgame
            end_game_delay = 20; //Set default value of delay
        end
        else
        begin
            end_game_delay = end_game_delay - 1; //Decrease value of delay
        end
    end
    else
	 
	 //If we continue game
	 
    begin

		  //Show blinking "apple"
		  
        HEX[apple_pos] <= ~HEX[apple_pos];
        apple_blink = (apple_blink + 1) % 5;
		  
        if (apple_blink == 0)
        begin
		  
            HEX[Queue[(head - length + 31) % 30]] = 1; //Switch HEX which number is defined the current position of head
            current_position = Queue[head] % 8; //Get current position of head from Queue

				//Generate delta for current move which helps to generate new positin of snake's head 
				
				delta = move(direction, horizontal, vertical, current_position);
				
				//Generate delta for turning right and left from current position
				
            if(direction == 0)
            begin
                turn_right = move(~direction, horizontal, 0, current_position);
                turn_left = move (~direction, horizontal, 1, current_position);
            end
            else
            begin
                turn_right = move(~direction, 0, vertical, current_position);
                turn_left = move (~direction, 1, vertical, current_position);
            end

				//Just reset neccessary values
				
            cross_turn_right = 0;
            cross_turn_left = 0;
            cross_tail = 0;
				
				//Generate the indicator of crossing snake's tail

            if (length > 1) //Such case can be if length is larger than 1
            begin
                for(i = 0; i <= 30; i = i + 1) // Go thought the Queue
                begin
					 
							//Here just define the part of queue we need
							
                    if(((head - length + 32) % 30 <= i && i <= head) || ((head - length + 32) % 30 > head 
						  && ((head - length + 32) % 30 <= i || i <= head)))
						  
                    begin
						  
								/*Generate new position of snake on current move which is depend on delta
								and check having such position in queue*/
								
                        if(Queue[i] == (Queue[head] + delta + 48) % 48)
                        begin
                            cross_tail = 1;
                        end
								
                    end
                end
            end
				
				//Generate the indicator of crossing the snake's body

            if (length > 2) //Such case can be if length of snake is larger than 2
            begin
                for(i = 0; i <= 30; i = i + 1) //Go thought the Queue
                begin
					 
					 		//Here just define the part of queue we need
					 
                    if(((head - length + 33) % 30 <= i && i <= head) || ((head - length + 33) % 30 > head && 
						  ((head - length + 33) % 30 <= i || i <= head)))
						  
                    begin
						  
								/*Generate the position of snake like it turn right from current position, and get segment's number from right
								and check having such segment's number in queue*/
								
                        if(Queue[i] == ((Queue[head] + turn_right + 48) % 48))
                        begin
                            cross_turn_right = 1;
                        end
								
								/*Generate the position of snake like it turn left from current position, and get segment's number from left
								and check having such segment's number in queue*/
								
                        if(Queue[i] == ((Queue[head] + turn_left + 48) % 48))
                        begin
                            cross_turn_left = 1;
                        end
								
                    end
                end
            end
				
				//Final check of crossing
				
				//If there are some body segments on right and left from current position, so snake cross body
				//If it's new position runs over the last segment of snake, it crosses the tail

            if(cross_turn_right && cross_turn_left || cross_tail)
            begin
                total_cross = 1;
            end

				//If we don't cross the snake, then do move which depend on already generated delta
			
            if(~total_cross)
            begin
                head = (head + 1) % 30; //Move ahead on one step, increase the position of head in queue
                Queue[head] = (Queue[(head + 29) % 30] + delta + 48) % 48; //And swith on right segment on display
                HEX[Queue[head]] = 0; //Swith off the last segment of snake on display

                //Generate "apple"

                if(apple_pos == Queue[head]) //Check eating "apple" on this step
                begin
                    length = length + 1; //Increase length of snake
						  
						  // Generate new position of appple
						  
                    apple_pos = (apple_pos + 31) % 48; 
						  
                    if (apple_pos % 8 == 7)
                    apple_pos = apple_pos - 1;
						  
                end
					 
					 //Check condition of winning game

                if(length == 6)
                begin
                    if (delay > 10)
                    begin
						  
                        delay = delay - 1; //Inrcrease speed
                        length = 1; //Set default value of length
								
								//Show message "COOL"
								
                        HEX = 48'b111111111000111010001000100010001000111111111111;
								
                        end_game = 1; //Indicator of ending game
								
                    end
                end
            end
            else
				
				//If sanke crossed itself
				
            begin
					
					 //Show message "U LOSE"

                HEX = 48'b100010011111111110001111100010001010001010000110;
					 
					 //Set default values

                for (i = 0; i <= 30; i = i + 1)
                Queue[i] = 0;

                end_game = 1;
                apple_blink = 0;
                apple_pos = 0;
                delay = 20;
                length = 1;
                total_cross = 0;
                cross_turn_right = 0;
                cross_turn_left = 0;
                cross_tail = 0;
					 
            end
        end
    end
end

//Main function for calculating delta for snake's movement

function integer move;

input integer direction, horizontal, vertical, current_position;

begin

	 /*Depeding on new direction calculate difference
		between segment's number of current position and new position*/
		
    if (direction == 0)
    begin
        if (current_position % 3 == 0)
        begin
            if (horizontal == 0) move = 8;
            else move = -8;
        end
        else
        begin
            if ((vertical == 0) && ((current_position == 2) || (current_position == 5)))
            begin
                if (current_position == 2)
                begin
                    if (horizontal == 0) move = 4;
                    else move = -4;
                end
                else
                begin
                    if (horizontal == 0) move = 9;
                    else move = 1;
                end
            end
            else if (vertical == 1 && (current_position == 1 || current_position == 4))
            begin
                if (current_position == 1)
                begin
                    if (horizontal == 0) move = -1;
                    else move = -9;
                end
                else
                begin
                    if (horizontal == 0) move = 4;
                    else move = -4;
                end
            end
            else
            begin
                if (current_position == 1 || current_position == 2)
                begin
                    if (horizontal == 0) move = 2;
                    else move = -6;
                end
                else
                begin
                    if (horizontal == 0) move = 7;
                    else move = -1;
                end

                if (current_position == 2 || current_position == 5)
                move = move - 1;
            end
        end
    end
    else
    begin // direction == 1
        if (current_position == 1 || current_position == 4) move = 1;
        else if (current_position == 5 || current_position == 2) move = -1;
        else if (current_position == 0)
        begin
            if (horizontal == 0)
            begin
                if (vertical == 0) move = 4;
                else move = 5;
            end
            else
            begin
                if (vertical == 0) move = 1;
                else move = 2;
            end
        end
        else if (current_position == 3)
        begin
            if (horizontal == 0)
            begin
                if (vertical == 0) move = 2;
                else move = 1;
            end
            else
            begin
                if (vertical == 0) move = -1;
                else move = -2;
            end
        end
        else if (current_position == 6)
        begin
            if (horizontal == 0)
            begin
                if (vertical == 0) move = -2;
                else move = -1;
            end
            else
            begin
                if (vertical == 0) move = -5;
                else move = -4;
            end
        end
    end

end

endfunction


reg pressed = 0; //Indicator of pressing button
reg applied = 0; // 1 if current button-press applied on current move

//Block for changing direction depending on which button is pressed

always @(posedge clockInp)
begin

    // Set indicators to deafult for correct dealing with pressing of buttons
    if (clockInp_count == 20000*delay)
        applied = 0; 
    if (KEY[0] == 1 && KEY[1] == 1)
        pressed = 0;

	 //If player pressed one button, change direction to right
	 
    if (KEY[0] == 0 && ~pressed && ~applied)
    begin
        pressed = 1;
        applied = 1;
        if (direction == 0)
        begin
            if (horizontal == 0)
            begin
                direction <= 1;
                vertical <= 1;
            end
            else
            begin
                direction <= 1;
                vertical <= 0;
            end
        end
        else
        begin
            if (vertical == 0)
            begin
                direction <= 0;
                horizontal <= 0;
            end
            else
            begin
                direction <= 0;
                horizontal <= 1;
            end
        end
    end
	 
	 //If player pressed another button, change direction to left

    if (KEY[1] == 0 && ~pressed && ~applied)
    begin
        pressed = 1;
        applied = 1;
        if (direction == 0)
        begin
            if (horizontal == 0)
            begin
                direction <= 1;
                vertical <= 0;
            end
            else
            begin
                direction <= 1;
                vertical <= 1;
            end
        end
        else
        begin
            if (vertical == 0)
            begin
                direction <= 0;
                horizontal <= 1;
            end
            else
            begin
                direction <= 0;
                horizontal <= 0;
            end
        end
    end
end

endmodule