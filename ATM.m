aircraft_count=40; % Number of aircraft in airspace
airspace_size=200; % Length of the square airspace
aircraft=Aircraft.empty; % Create an aircraft with no values assigned to properties

for i=1:aircraft_count
    aircraft(i)=Aircraft(rand*200,rand*200); %Create aircraft with random position in airspace
end

manouvre=Manouvre(aircraft,[airspace_size, airspace_size]); %Initializes properties of manouvre class
f= figure(); % Create figure for visualisation
%f= figure('visible','off'); %For an invisible figure
airspace=Airspace(f,[airspace_size airspace_size],aircraft); %Initialize figure with aircraft placed in them 
manouvre.run(airspace); 