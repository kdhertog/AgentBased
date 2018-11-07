%% final3_concludeSimulation.m description
% This file calculates the realized fuel savings (percentual and absolute),
% the extra flight time due to formation flying, and the extra distance
% flown due to formation flying. Some additional performance indicators are
% calculated in this file.

% It contains one function: calculateResults.m.

%% Concluding data.

% This function determines the realized fuel savings, the extra flight time
% due to formation flying, and the extra distance flown due to formation
% flying.
[fuelSavingsTotalPct,fuelSavingsAlliancePct, ...
    fuelSavingsNonAlliancePct,extraDistancePct,extraFlightTimePct, ...
    numberOfFormations,delayLeftNonAlliance, delayLeftAlliance, ...
    fuelSaveDelayRatio, fuelSaveDelayRatioAlliance, fuelSaveAlliance, ...
    fuelSaveNonAlliance] = ...
    calculateResults(nAircraft,flightsDataRecordings,Wfinal,Vmax, ...
    fuelSavingsTotal, flightsData, percentageAlliance);



% Actual fuel savings, comparing the actual fuel use to the total fuel
% use if of only solo flights were flown.
fuelSavingsTotalPerRun(simrun) = fuelSavingsTotal; % [kg]

% Percentual fuel savings, comparing the actual fuel use to the total fuel
% use if of only solo flights were flown.
fuelSavingsTotalPctPerRun(simrun) = fuelSavingsTotalPct; % [%]

% Percentage of the total fuel savings that went to the alliance.
fuelSavingsAlliancePctPerRun(simrun) = fuelSavingsAlliancePct; % [%]

% Percentage of the total fuel savings that went to the non-alliance
% flights.
fuelSavingsNonAlliancePctPerRun(simrun) = fuelSavingsNonAlliancePct; % [%]

% Percentual change in total distance, comparing the actual total distance
% to the total distance if only solo flights were flown.
extraDistancePctPerRun(simrun) = extraDistancePct; % [%]

% Percentual change in total flight, comparing the actual flight time to
% the total flight time of only solo flights were flown.
extraFlightTimePctPerRun(simrun) = extraFlightTimePct; % [%]
 
%The number of fomrations that were created in the simulation loop
numberOfFormationsPerRun(simrun) = numberOfFormations;

%The total allowed delay left for non alliance flights
delayLeftNonAlliancePerRun(simrun) = delayLeftNonAlliance;

%The total allowed of delay left for alliance flights
delayLeftAllaincePerRun(simrun) = delayLeftAlliance;

%Fuel saved devided by the total delay
fuelSaveDelayRatioPerRun(simrun) = fuelSaveDelayRatio;

%Fuel saved of the allaince devided by the total delay of the
%alliance
fuelSaveDelayRatioAlliancePerRun(simrun) = fuelSaveDelayRatioAlliance;

%Total fuel saved by the Alliance
fuelSaveAlliancePerRun(simrun) = fuelSaveAlliance;

%Total fuel saved by the non Alliance flights
fuelSaveNonAlliancePerRun(simrun) = fuelSaveNonAlliance;

%% Clear some variables.

clearvars a acNr1 acNr2 c communicationCandidates divisionFutureSavings ...
    flightIDsFollowers flightsArrived flightsAtCurrentLocation ...
    flightsDeparted flightsNotMovedYet flightsOvershot followersOfFlightA ...
    fuelSavingsOffer i j m n nCandidates potentialFuelSavings s ...
    syncPossible timeAdded_acNr1 timeAdded_acNr2 timeWithinLimits ...
    travelledDistance travelledDistanceX travelledDistanceY ...
    uniqueFormationCurrentLocations VsegmentAJ_acNr1 VsegmentBJ_acNr2 ...
    wAC wBD wDuo Xjoining Xordes Xsplitting Yjoining Yordes Ysplitting ...
    extraDistancePct extraFlightTimePct fuelSavingsAlliancePct ...
    fuelSavingsNonAlliancePct fuelSavingsTotal fuelSavingsTotalPct ...
    extraDistancePct extraFlightTimePct numberOfFormations ...
    delayLeftNonAlliance delayLeftAlliance fuelSaveDelayRatio ...
    fuelSaveDelayRatioAlliance fuelSaveAlliance fuelSaveNonAlliance