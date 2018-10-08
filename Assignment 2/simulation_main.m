%% simulation_main.m description
% This file should be run to simulate flight operations. The code is split
% up in ten main files: prep1_setParameters.m, prep2_loadFixedParameters.m,
% prep3_performanceIndicators.m, prep4_loadFlightSchedule.m,
% step1_performCommunication.m, step2_moveAircraft.m,
% step3_determineFormationLeaders.m, final1_visualizeAirports.m,
% final2_visualizeFlights.m, and final3_concludeSimulation.m. Each of these
% files may contain (multiple) help functions.

% The main file you will work in is step1a_doNegotiation_*.m. You are
% allowed to make changes to all other functions, as long as you clearly
% comment the code and document the changes. Examples of why such changes
% may be necessary are to implement performance indicators (in prep3_.m and
% final3_.m), or to add more properties to agents (in generateFlights.m).

%% Assumptions.
% For more information, see Ch. 4.2 of Verhagen's thesis.

% * One type of aircraft.
% * Any effect of wind is not included in the model.
% * At the end of a solo mission, an aircraft would be out of fuel. This is
% used to determine the starting weight of an aircraft.
% * Flying in formation will change the trailing aircraft's M-value from
% 140 to 158 (the fuel consumption of an aircraft is governed by these
% M-values.  This corresponds to a fuel flow reduction of 10%. For more
% information, see Ch. 5.3.2 of Verhagen's thesis).
% * Formation size does not affect the M-value of trailing aircraft. This
% is a conservative assumption, as it is expected that efficiency increases
% with formation size.
% * All aircraft fly at an altitude of 11 [km].
% * When entering the simulation, an aircraft is immediately at 11 [km] and
% at Vmax.
% * The speed range is M0.7 (Vmin) - M0.85 (Vmax).
% * Every aircraft flies at equal speed (Vmax), unless required otherwise
% for synchronization purposes.
% * For synchronization purposes only delaying flights is considered, as
% speeding up is unlikely to be fuel efficient at M0.85.
% * It has been decided that in this work, if for synchronization purposes
% a new joining point has to be chosen, this is always on the original
% formation flight segment.
% * An attempted formation is always succesful.
% * In the code a formation is represented by a dummy flight, which will
% lead the formation. Later in the code, the real flight in the formation
% with the lowest flight ID will be the actual formation leader. The
% M-value of this flight is then adjusted to the solo value.
% * In the code, the flight with the lowest flight ID will be the formation
% leader at all times. As a consequence, it can occur that due to
% synchronization efforts this flight will arrive at its destination with
% negative fuel weight. In reality, it is assumed flights will rotate the
% formation leader position such that all flights in the formation have
% sufficient fuel to reach their destination.
% * Approximately every 60 seconds one aircraft departs. Time [s] between
% flights taking off is based on a typical day of eastbound transatlantic
% flights.
% * Flights must be eastbound for the code to work.

%% Clear workspace and command window, add paths for help functions and files.
 
% Close figures.
close all
% Clear workspace.
clearvars 
% Clear command window.
clc
% Add paths.
addpath('helpFunctions')
addpath('simulationSteps')
addpath('agentModels')
addpath('agentModels/CNP') 
addpath('agentModels/Dutch') 
addpath('agentModels/English') 
addpath('agentModels/Vickrey') 
addpath('agentModels/Japanese') 
addpath('agentModels/first') 

%% Load parameters, predefine performance indicators.

% Set variable parameters.
prep1_setParameters;
% Load fixed parameters.
prep2_loadFixedParameters;

% Sets the correct negotiation technique file for the simulation runs.
step1a_doNegotiation = str2func(char(negotiationFiles(negotiationTechnique)));

% Predefine variables that will be used to track performance indicators
% over the simulation runs.
prep3_performanceIndicators;

%% Carry out the simulation runs.
for simrun = 1:nSimulations
    %% Prepare the (new) simulation run.

    % Generate the initial properties for each real flight and create the
    % random flight schedule.
    prep4_loadFlightSchedule;
        
    % Remove previously obtained data from the variables.
    clearvars flightsDataRecordings flightsDataReal flightsData

    % Load the initial flight data. 
    flightsData = flightsInitialData;

    % Get the initial values into the flight data recorder. This will be
    % used to visualize the results.
    flightsDataRecordings(1,:,:) = flightsData;
    flightsDataReal(1,:,:) = flightsData(1:nAircraft,:);

    % Set the time step to 1. This is not a unit of time, but will
    % be used to record the flight data and visualize the results. The
    % size of each time step is dt.
    t = 1;  
        
    % Predefine number of dummy flights used.
    dummyCounter = 0;   
    % Predefine total fuel savings. 
    fuelSavingsTotal = 0;       
    
    % Visualize the origin and destination airports. 
    if visualizationOption == 1
        final1_visualizeAirports;
    end                 
     
    %% Current simulation run is carried out here.
    
    % Runs while not every real flight has arrived yet (excludes dummy
    % flights).
    while sum(flightsData(1:nAircraft,18)) < nAircraft                          
        % Go through the three steps of the simulation.
        step1_performCommunication;
        step2_moveAircraft;
        step3_determineFormationLeaders;

        % Iterate to the next time step.
        t = t+1;                                                                    

        % Store the data in time step t of the flight recorders.
        flightsDataRecordings(t,:,:) = flightsData;                                    
        flightsDataReal(t,:,:) = flightsData(1:nAircraft,:); 
        
        % Visualize the flights. 
        if visualizationOption == 1
            final2_visualizeFlights;
        end
    end

    %% Store performance indicators of current simulation run.
    % Calculate the realized fuel savings, the extra flight time due to
    % formation flying, and the extra distance flown due to formation
    % flying.
    final3_concludeSimulation;
end