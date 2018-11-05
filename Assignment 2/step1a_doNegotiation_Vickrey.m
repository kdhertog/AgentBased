%% step1a_doNegotiation_Vickrey.m description
% Add your Vickrey agent models and edit this file to create your Vickrey
% auction.

% This file uses the matrix generated in determineCommunicationCandidates.m
% (in step1_performCommunication.m) that contains every communication
% candidate for each flight. The function
% determineRoutingAndSynchronization.m then determines if formation is
% possible for a pair of flights, the optimal joining- and splitting point,
% and what their respective speeds should be towards the joining point to
% arrive at the same time. The function calculateFuelSavings.m then
% determines how much cumulative fuel is saved when accepting this
% formation flight. If accepted, the properties in flightsData (the matrix
% that contains all information of each flight) for both flights are
% updated in step1c_updateProperties.m.

% Make sure that the following variables are assigned to those belonging to
% the combination of the manager/auctioneer agent (acNr1) and the winning
% contractor/bidding agent (acNr2): acNr2, fuelSavingsOffer,
% divisionFutureSavings. Also: Xjoining, Yjoining, Xsplitting, Ysplitting,
% VsegmentAJ_acNr1, VsegmentBJ_acNr2, timeAdded_acNr1, timeAdded_acNr2,
% potentialFuelSavings. These variables follow from
% step1b_routingSynchronizationFuelSavings.m and differ for every
% combination of acNr1 and acNr2.

% One way of doing this is storing them as part of the bid, and then
% defining them again when the manager awards the contract in the CNP/the
% winning bid is selected in the auctions.

% It contains two files: step1b_routingSynchronizationFuelSavings.m
% (determineRoutingAndSynchronization.m, calculateFuelSavings.m) and
% step1c_updateProperties.m.


%% Loop through the combinations of flights that are allowed to communicate.

%Create an array with each aircraft and how many possible communication
%partners there are for each aircraft. The one with most possible
%connection is selected as first for auctioneer. 
NumberofCandidates=[];
for i = 1:length(communicationCandidates(:,1)) 
    NumberofCandidates=[NumberofCandidates;communicationCandidates(i,1),nnz(communicationCandidates(i,2:end))]; %#ok<AGROW>
end
Auctioneerorder=sortrows(NumberofCandidates,2,'descend');

for i = 1:length(communicationCandidates(:,1))     
    % Store flight ID of flight i in variable.
    acNr1 = Auctioneerorder(i,1);     
    
    % Determine the number of communication candidates for flight i.
    nCandidates = Auctioneerorder(i,2); 
    
    %Bids for each auction are stored in the following list. The first
    %entry is the flight ID, second is the fuel saved over delay mutiplied 
    %times the division. Third is the devision ratio for acNr1 w.r.t. the 
    %total earnings. The forth parameter determines if the bid comes from 
    %the alliance or not.
    Bids=[];
    
    %Check if the aircraft is able to communicate, if it has candidates to
    %communicate with, and if it can have additional delay. If this is the
    %case the agent will become auctioneer.
    if flightsData(acNr1,2) == 1 && nCandidates > 0 && ...
            flightsData(acNr1,26) > managerDelayDecision
        
        %Find out wether the leader of the group is part of the alliance or
        %not. To determine this, first the aircraft in formation need to be determined.
        %If they do not fly in formation the alliance can be retrieved
        %directly
        if flightsData(acNr1,17) == 1          
            AircrafInFormation=find(flightsData(1:nAircraft,8)==flightsData(acNr1,8) & ...
                flightsData(1:nAircraft,14)==flightsData(acNr1,14) & ...
                flightsData(1:nAircraft,15)==flightsData(acNr1,15) & ...
                flightsData(1:nAircraft,16)==flightsData(acNr1,16));
            acLeader=min(AircrafInFormation);
            AllianceacNr1=flightsData(acLeader,25);
        else
            AllianceacNr1=flightsData(acNr1,25);
        end 
        
        %Initially all communication candidates have the option to bid in
        %the auction
        bidders = communicationCandidates;
        
        %Find the index acNr1 in the list of bidders
        IndexacNr1 = find(bidders(:,1)==acNr1);
        
        %Start the auction
        auction = 1;
        
        while auction == 1
            
        end
    end
end


