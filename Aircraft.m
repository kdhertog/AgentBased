classdef Aircraft
    
    properties
        position
        velocity
        vision
        seperation
        turncount
        heading
    end
    
    methods
        function obj = Aircraft(position_x, position_y)
            obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            
            %[position_x, position_y]
            %OR check for other borders
            %[[position_x, position_y] [position_x-200., position_y+200]
            %[position_x, position_y+200] [position_x+200, position_y+200] [position_x-200,
            %position_y] [position_x+200, position_y] [position_x-200, position_y-200]
            %[position_x, position_y-200] [position_x-200, position_y-200]]
            
            obj.heading = (2*pi).*rand;
            obj.velocity = [cos(obj.heading), sin(obj.heading)];
        
            obj.vision = 50;
            obj.seperation = 20;
            obj.turncount =0;
            
        end
        
        function obj = reactiveturn(obj, near_aircraft)
            
            if near_aircraft == 1
                if obj.turncount <= 0
                    obj.heading = obj.heading+pi/6;
                    obj.velocity = [cos(obj.heading), sin(obj.heading)];
                    obj.turncount = 3;
                else
                    obj.turncount = obj.turncount - 1;
                end
            else
                obj.turncount = obj.turncount - 1;
            end
        end
        
        function obj = proactiveturn(obj, near_aircraft_list)
            near_aircraft_headings = []; %List of the relative position (angle) of the near aircraft
            for i = 1:length(near_aircraft_list) %Near_aircraft_list compasses the id's of all near aircraft
                distance_aircraft=100000;
                for j=1:length(obj.position)/2
                   distance_x_option = (obj.position(1) - near_aircraft_list(i).position(2*j-1));
                   distance_y_option = (obj.position(2) - near_aircraft_list(i).position(2*j));
                   distance_option=sqrt(distance_x_option^2+distance_y_option^2);
                            
                   if distance_option<distance_aircraft
                       distance_aircraft=distance_option;
                       distance_x = distance_x_option;
                       distance_y = distance_y_option;
                   end
                    
                end
                 
                near_aircraft_relative_position = atan2d(distance_y,distance_x) + 360*(distance_y<0); %For every near aircraft the relative position_angle gets calculated, and stored in a list
                temp=[near_aircraft_headings,near_aircraft_relative_position];
                near_aircraft_headings=temp; %In the end of the for loop, near_aircraft_headings compasses the relative positions off all near aircraft, tough they are not cooupled to a certain aircraft
                     
            end
            
            compass_divisions = 72;
            divided_compass = 360/compass_divisions;
            heading_score = [];
            for i = 1:compass_divisions
                temp1 = length(near_aircraft_headings(i*divided_compass-divided_compass <= near_aircraft_headings & near_aircraft_headings < i*divided_compass));
                temp2 = [heading_score,temp1];
                heading_score = temp2;
            end
            
%             [~, optimal_heading] = min(heading_score);
%             obj.heading = deg2rad(optimal_heading * divided_compass);
%             obj.velocity = [cos(obj.heading), sin(obj.heading)];

            [~, worst_heading] = max(heading_score);
            obj.heading = worst_heading * divided_compass + 180;
            obj.velocity = [cos(obj.heading), sin(obj.heading)];
            
%             disp(obj.position)
%             disp(heading_score)
%             disp(optimal_heading)
%             disp(" ")
%             disp(" ")
            
            
        end
               
        function obj = update(obj)
           position_x = obj.position(1) + obj.velocity(1);
           position_y = obj.position(2) + obj.velocity(2);
           obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            
        end
        
        function obj = borders(obj, airspace_size)
            if obj.position(1) < 0
                position_x = obj.position(1)+airspace_size;
                position_y = obj.position(2);
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            end
            
            if obj.position(2) < 0
                position_x = obj.position(1);
                position_y = obj.position(2)+airspace_size;
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            end
            
            if obj.position(1) > airspace_size
                position_x = obj.position(1)-airspace_size;
                position_y = obj.position(2);
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            end
            
            if obj.position(2) > airspace_size
                position_x = obj.position(1);
                position_y = obj.position(2)-airspace_size;
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            end 
            
        end
        
    end 
    
end
           