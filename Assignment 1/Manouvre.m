classdef Manouvre

    properties
        aircraft
        airspace_size 
        step_counter=0; %Current step
<<<<<<< HEAD:Assignment 1/Manouvre.m
        max_step=500; % Number of steps per simulation
        conflict_list=[0]; %List keeps track of conflicts over time
        true_collision_count=0;
=======
        max_step=100; % Number of steps per simulation
        conflict_list=0; %List keeps track of conflicts over time
        true_collision_count=0; % Keeps track of the amount of times an aircraft is within a distance of 1 between each other
>>>>>>> cd7ee68f0a1911766f510e8ebdd30fa69a9807e2:Manouvre.m
        clustering
        model_type
    end
    
    methods
        
        function obj = Manouvre(aircraft, airspace_size, model)
            obj.aircraft=aircraft; %List of aircraft
            obj.airspace_size=airspace_size; %Size of the airspace
            obj.clustering=zeros(4,obj.max_step); %Keep track of clustering per tick
            obj.model_type = model; %Reactive (0) or proactive (1)
            %CLustering is defined as the amount of aircraf in four evenly
            %devided areas. 
        end
        
        function run(obj, airspace)
            while true
                obj = distance_aircraft(obj); %Calculate distance between all aircraft and check if they have to react. 
                obj = update_aircraft(obj); % New location of aircraft
                obj = borders(obj); % Check for crossing borders
                
                [obj,airspace] = render(obj,airspace); %Plot aircraft in graph
                obj.step_counter=obj.step_counter+1; % Go to next step
                
                obj = cluster(obj); % Gather data for analyzing clustering
                
                if obj.step_counter >= obj.max_step 
                    graphs(obj);
                    break % Stop simulation
                end
            end
        end
        
        function obj = graphs(obj)
            disp(['Number of conflicts: ' , num2str(obj.conflict_list(end))])
            disp(['Number of collisions: ' , num2str(obj.true_collision_count)])

            %Display clustering of aircraft in certain areas of the map.
            %According to the following distribution
            
            %##--------##--------##
            %## Area 1 ## Area 2 ##
            %##--------##--------##
            %## Area 3 ## Area 4 ##
            %##--------##--------##
            
            subplot(2,1,1);
            x_plot = 1:1:obj.max_step;
            plot(x_plot,obj.clustering(1,:));
            title('Distribution plot')
            ylim([0 inf])
            xlim([1 obj.max_step])
            xlabel('Iteration number')
            ylabel('Number of agents')

            hold on

            plot(x_plot,obj.clustering(2,:))
            plot(x_plot,obj.clustering(3,:))
            plot(x_plot,obj.clustering(4,:))

            legend('Area 1','Area 2','Area 3','Area 4', 'Location','southwest')
            % Area 1 = top left
            % Area 2 = top right
            % Area 3 = bottom left
            % Area 4 = bottom right
            
            hold off

            subplot(2,1,2); % Create the plot of conflicts over time
            x=0:1:obj.max_step;
            plot(x,obj.conflict_list)
            xlabel('Iteration number')
            ylabel('Number of conflicts')
        end
            
       
        function obj = cluster(obj) % For each tick the number of aircraft in each divided area is counted. 
            for i=1:length(obj.aircraft)
                position_x=obj.aircraft(i).position(1);
                position_y=obj.aircraft(i).position(2);
                
                if position_x<obj.airspace_size(1)*0.5
                    if position_y>obj.airspace_size(2)*0.5 % Aircraft is in top left corner
                        obj.clustering(1,obj.step_counter)=obj.clustering(1,obj.step_counter)+1;
                    else % Aircraft is in top right corner
                        obj.clustering(3,obj.step_counter)=obj.clustering(3,obj.step_counter)+1;
                    end
                else
                    if position_y>obj.airspace_size(2)*0.5 % Aircraft is in bottom left corner
                        obj.clustering(2,obj.step_counter)=obj.clustering(2,obj.step_counter)+1;
                    else %Aircraft is in bottom right corner
                        obj.clustering(4,obj.step_counter)=obj.clustering(4,obj.step_counter)+1;
                    end
                end
            end
        end
        
        function obj = update_aircraft(obj) % Change position of aircraft in heading direction
            for i=1:length(obj.aircraft)
                obj.aircraft(i)=obj.aircraft(i).update(); 
            end
        end
        
        function obj = borders(obj) % Change position of aircraft if it exceeds borders
            for i=1:length(obj.aircraft)
                obj.aircraft(i)=obj.aircraft(i).borders(obj.airspace_size(1));
            end
        end
        
        function [obj,airspace] = render(obj,airspace) % Update the figure with the aircraft in their new position
                      
           for i=1:length(obj.aircraft)
               delete(airspace.aircraft_figure_handles(i)); %Delete aircraft on their previous posiion
              
%              Drawing circels with half the radius of a conflict around
%              each agent.
               t = linspace(0, 2*pi);
               r1 = obj.aircraft.seperation ;
               x1 = obj.aircraft(i).position(1)+0.5*r1*cos(t);
               y1 = obj.aircraft(i).position(2)+0.5*r1*sin(t);
                

               airspace.aircraft_figure_handles(i) = patch(x1,y1,'red');
           end
           alpha(0.3) % Set transparency of circles
           drawnow;
            
        end
        
        
        function obj = distance_aircraft(obj)
            collisions_per_turn=obj.conflict_list(end);
            for i=1:length(obj.aircraft)
                %reactive agent
                turn = 0; % Binary
                % proactive agent  
                aircraft_in_vision=[]; %Create a list of integers of aircraft within their vision
                for j=1:length(obj.aircraft)
                    if i~=j % Comparing two of the same aircraft should not count as a collision
                        distance_aircraft=100000; % Create arbitrary large distance as starting point
                        for k=1:length(obj.aircraft(i).position)/2 %Find closest ditance, also by crosing borders
                            distance_x = (obj.aircraft(i).position(1)- obj.aircraft(j).position(2*k-1));
                            distance_y = (obj.aircraft(i).position(2)- obj.aircraft(j).position(2*k));
                            distance_option=sqrt(distance_x^2+distance_y^2);
                            
                            if distance_option<distance_aircraft
                                distance_aircraft=distance_option; % This is the shortest distance between the two aircraft, this can be indirect through a border.
                            end
                            
                       
                        end
                        
                        if distance_aircraft<obj.aircraft(i).seperation % Check if they are to close to each other
                            collisions_per_turn=collisions_per_turn+0.5; % A conflict counts for 0.5 since both aircraft will see that they are to close to each other/ 
                            
                            if distance_aircraft<1 % If the two aircraft actually collide with each other
                                obj.true_collision_count = obj.true_collision_count+0.5;
                            
                            end
                        end
                        
                        %reactive agent
                        if distance_aircraft<obj.aircraft(i).vision %Check if the reactive agent has to react
                            turn = 1;
                        end
                        
                        %proactive agent
                        if distance_aircraft<obj.aircraft(i).seperation + (obj.aircraft(i).vision-obj.aircraft(i).seperation)*0.1
                            temp=[aircraft_in_vision,j];
                            aircraft_in_vision=temp;  
                        end
                    
                    end
                end
                
                %reactive agent
                if obj.model_type == 0
                    obj.aircraft(i)=obj.aircraft(i).reactiveturn(turn);
                end
                         
                %proactive agent
                if obj.model_type == 1
                    if ~isempty(aircraft_in_vision) % If there is an aircraft in vision the proactive aircraft should perform a heading change
                        aircraft_in_vision_aircraft = [];
                        for l = 1:length(aircraft_in_vision) %Construction to convert the id of the ac in vision to actual aircraft, en use that as input for proactiveturn
                            temp = [aircraft_in_vision_aircraft,obj.aircraft(aircraft_in_vision(l))];
                            aircraft_in_vision_aircraft = temp;
                        end

                        obj.aircraft(i) = obj.aircraft(i).proactiveturn(aircraft_in_vision_aircraft);
                    end
                end
            end
            temp=[obj.conflict_list,collisions_per_turn];
            obj.conflict_list=temp; % Add the conflicts of the current tick to the total list, containing collisions per tick
        end  
        
    end  
end
