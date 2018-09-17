classdef Manouvre

    properties
        aircraft
        airspace_size
        step_counter=0;
        max_step=100;
        collision_count=0;
        clustering
    end
    
    methods
        
        function obj = Manouvre(aircraft, airspace_size)
            obj.aircraft=aircraft;
            obj.airspace_size=airspace_size;
            obj.clustering=zeros(4,100);
        end
        
        function run(obj, airspace)
            while true
                obj = distance_aircraft(obj);
                obj = update_aircraft(obj);
                obj = borders(obj);
                
                [obj,airspace] = render(obj,airspace);
                obj.step_counter=obj.step_counter+1;
                
                obj = cluster(obj);
                
                disp(['Render ', num2str(obj.step_counter)])
                if obj.step_counter >= obj.max_step
                    disp(['Number of collisions: ' , num2str(obj.collision_count/2)])
                    
                    %Display clustering
                    x_plot = linspace(0,obj.max_step);
                    plot(x_plot,obj.clustering(1,:));
                    title('Distribution plot')
                    ylim([0 inf])
                    xlabel('Itteration number')
                    ylabel('Number of agents')
                    
                    hold on
                    
                    plot(x_plot,obj.clustering(2,:))
                    plot(x_plot,obj.clustering(3,:))
                    plot(x_plot,obj.clustering(4,:))
                    
                    legend('Area 1','Area 2','Area 3','Area 4', 'Location','southwest')
                    
                    hold off
                    
                   
                    break
                end
            end
        end
        
        function obj = cluster(obj)
            for i=1:length(obj.aircraft)
                position_x=obj.aircraft(i).position(1);
                position_y=obj.aircraft(i).position(2);
                
                if position_x<obj.airspace_size(1)*0.5
                    if position_y>obj.airspace_size(2)*0.5
                        obj.clustering(1,obj.step_counter)=obj.clustering(1,obj.step_counter)+1;
                    else
                        obj.clustering(3,obj.step_counter)=obj.clustering(3,obj.step_counter)+1;
                    end
                else
                    if position_y>obj.airspace_size(2)*0.5
                        obj.clustering(2,obj.step_counter)=obj.clustering(2,obj.step_counter)+1;
                    else
                        obj.clustering(4,obj.step_counter)=obj.clustering(4,obj.step_counter)+1;
                    end
                end
            end
        end
        
        function obj = update_aircraft(obj)
            for i=1:length(obj.aircraft)
                obj.aircraft(i)=obj.aircraft(i).update();
            end
        end
        
        function obj = borders(obj)
            for i=1:length(obj.aircraft)
                obj.aircraft(i)=obj.aircraft(i).borders(obj.airspace_size(1));
            end
        end
        
        function [obj,airspace] = render(obj,airspace)
                      
           for i=1:length(obj.aircraft)
               delete(airspace.aircraft_figure_handles(i));
               
%                x=[obj.aircraft(i).position(1) obj.aircraft(i).position(1)+1 obj.aircraft(i).position(1)+1 obj.aircraft(i).position(1)];
%                y=[obj.aircraft(i).position(2) obj.aircraft(i).position(2) obj.aircraft(i).position(2)+1 obj.aircraft(i).position(2)+1];

%                Drawing circels
               t = linspace(0, 2*pi);
               r1 = obj.aircraft.seperation ;
               x1 = obj.aircraft(i).position(1)+0.5*r1*cos(t);
               y1 = obj.aircraft(i).position(2)+0.5*r1*sin(t);
                

               airspace.aircraft_figure_handles(i) = patch(x1,y1,'red');
%                airspace.aircraft_figure_handles(i) = patch(x,y,'green'); ;
            
           end
           alpha(0.3)
           drawnow;
            
        end
        
        function obj = distance_aircraft(obj)
            for i=1:length(obj.aircraft)
                %reactive agent
                %turn = 0;
                % proactive agent  
                aircraft_in_vision=[];
                for j=1:length(obj.aircraft)
                    if i==j
                        obj.collision_count = obj.collision_count+0;
                    else
                        distance_aircraft=100000;
                        for k=1:length(obj.aircraft(i).position)/2
                            distance_x = (obj.aircraft(i).position(1)- obj.aircraft(j).position(2*k-1));
                            distance_y = (obj.aircraft(i).position(2)- obj.aircraft(j).position(2*k));
                            distance_option=sqrt(distance_x^2+distance_y^2);
                            
                            if distance_option<distance_aircraft
                                distance_aircraft=distance_option;
                            end
                            
                       
                        end
                        
                        if distance_aircraft<obj.aircraft(i).seperation
                            obj.collision_count = obj.collision_count+1;
                        end
                        
%                         %reactive agent
%                         if distance_aircraft<obj.aircraft(i).vision
%                             turn = 1;
%                         end
                        
                        %proactive agent
                        if distance_aircraft<obj.aircraft(i).seperation + 3 %CHANGE BACK TO VISION!!!!vision
                            temp=[aircraft_in_vision,j];
                            aircraft_in_vision=temp;
                        end
                    
                    end
                end
                %reactive agent
                %obj.aircraft(i)=obj.aircraft(i).reactiveturn(turn);
                               
                %proactive agent
                if ~isempty(aircraft_in_vision)
                    aircraft_in_vision_aircraft = [];
                    for l = 1:length(aircraft_in_vision) %Construction to convert the id of the ac in vision to actual aircraft, en use that as input for proactiveturn
                        temp = [aircraft_in_vision_aircraft,obj.aircraft(aircraft_in_vision(l))];
                        aircraft_in_vision_aircraft = temp;
                    end
                        
                    obj.aircraft(i) = obj.aircraft(i).proactiveturn(aircraft_in_vision_aircraft);
                end
            end
        end
        
        
%         function obj = collision(obj)
%             count=0;
%             for i=1:length(obj.aircraft)
%                 for j=1:length(obj.aircraft)
%                     if i==j
%                         count = count+0;
%                     else
%                         distance = distant(obj.aircraft(i).position, obj.aircraft(j).position);  
%                         count = count+1;
%                     end
%                     
%                 end
%                     
%             end
%             
%         end
        
        
    end  
end
