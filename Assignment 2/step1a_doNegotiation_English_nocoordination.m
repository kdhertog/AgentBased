%% step1a_doNegotiation_English.m description
% Add your English agent models and edit this file to create your English
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

fuelSaveDelayRatioRequired = 30;

factorNonAllianceAuctioneer = 0.8;

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
    
    %Constant used for waying if agent i has enough max_delay left to
    %become a manager. This can be bigger than 0. 
    managerDelayDecision = 0;
    
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
        
        %Find the index acNr1 in the list of communicationCandidates
        IndexacNr1 = find(communicationCandidates(:,1)==acNr1);
        
        %Initially all communication candidates of acNr1 have the option to bid in
        %the auction. Zero elements have to be removed from the bidder
        %array
        bidders = communicationCandidates(IndexacNr1,:);
        bidders(bidders==0) = [];
        
        %Determine whether an auction has to take place
        nBidders = length(bidders) - 1;
        if nBidders > 1
            
            %Start the auction
            auction = 1;
      
            while auction == 1
                
                %test = "New For Loop"
                BiddersToBeRemoved = [];
                for j = 1:nBidders
                    acNr2 = bidders(j+1);
                    IndexacNr2 = find(bidders==acNr2);

                    %Determine if acNr2 & acNr1 are still available for
                    %communication BUG FIX FROM BS FORUM (%if
                    %flightsData(acNr2,2) == 1 && flightsData(acNr1,2) == 1)
                    if flightsData(acNr1,2) == 1 && flightsData(acNr2,2) == 1 && ...
                    (flightsData(acNr1,14) ~= flightsData(acNr2,14) &&  flightsData(acNr1,15) ~= flightsData(acNr2,15))
                        %test = "Communicate"

                        %Determine if the formation leader of acNr2 is part of the allaince or not
                        %This is checked by looking at all aircraft with the
                        %same coordinates.
                        if flightsData(acNr2,21) == 2          
                            AircrafInFormation=find(flightsData(1:nAircraft,8)== ...
                                flightsData(acNr2,8) & ...
                            flightsData(1:nAircraft,14)==flightsData(acNr2,14) & ...
                            flightsData(1:nAircraft,15)==flightsData(acNr2,15) & ...
                            flightsData(1:nAircraft,16)==flightsData(acNr2,16));
                            acLeader=min(AircrafInFormation);
                            AllianceacNr2=flightsData(acLeader,25);
                        else
                            AllianceacNr2=flightsData(acNr2,25);
                        end 

                        step1b_routingSynchronizationFuelSavings

                        %Determine to bid or not. If there is a potential for
                        %FuelSavings, the agent wants to bid. 
                        bidDecisionFactor = potentialFuelSavings;
                        bidTreshold = 0; %bidDecision factor should be bigger than this

                        if bidDecisionFactor > bidTreshold

                                FuelDelayRatio = potentialFuelSavings/ ...
                                    (timeAdded_acNr1+timeAdded_acNr2);

                                %determine private value
                                if AllianceacNr1 == 2 && AllianceacNr2 == 2 %Both are in the alliance, so they want to work together no matter what
                                    privateValue = 1.0;
                                elseif AllianceacNr1 == 1 && AllianceacNr2 == 2 %Alliance bidder has a lower willingness to work with non alliance 
                                    privateValue = (1 - (fuelSaveDelayRatioRequired / (potentialFuelSavings/timeAdded_acNr2))) * factorNonAllianceAuctioneer;
                                else
                                    privateValue = 1 - (fuelSaveDelayRatioRequired / (potentialFuelSavings/timeAdded_acNr2));
                                end
                                
                                %Determine the height of the bid, which will be
                                %5 percent heigher than the previous bid.
                                if isempty(Bids) == 0
                                    bestBidHeight = max(Bids(:,2));
                                    currentBidHeight = bestBidHeight * 1.05;
                                else
                                    currentBidHeight = FuelDelayRatio * 0.1; %We start with an obvious advantage for the bidder
                                end

                                %Determine devision required to make the bid
                                devision = currentBidHeight / FuelDelayRatio;

                                %Either bid, or, if this is not possible, quit
                                %the auction
                                bidValue = devision;
                                if bidValue <= privateValue
                                    %test = "BID"
                                    %add bid to Bids
                                    Bids = [Bids;acNr2,FuelDelayRatio*devision ...
                                        ,devision,AllianceacNr2]; %#ok<AGROW>

                                else %Remove agent from bidders
                                    %test = "REMOVE BIDDER1"
                                    BiddersToBeRemoved = [BiddersToBeRemoved,IndexacNr2]; %#ok<AGROW>
                                end

                        else
                                %The agent does not want to bid, so he gets
                                %removed from the collection of bidders
                                %test = "REMOVE BIDDER2"
                                BiddersToBeRemoved = [BiddersToBeRemoved,IndexacNr2]; %#ok<AGROW>
                        end
                        
                    else
                        %The agent is not able to communicate, so he gets
                        %removed from the collection of bidders
                        %test = "REMOVE BIDDER3"
                        BiddersToBeRemoved = [BiddersToBeRemoved,IndexacNr2]; %#ok<AGROW>
                    end
                    
                end
                
                %Remove bidders from the bidder list
                bidders(BiddersToBeRemoved) = [];
                nBidders = length(bidders)-length(BiddersToBeRemoved)-1;
                
                %Determine whether the auction can end. This is the case
                %when there is one (or zero) bidders left. 
                if nBidders <= 1 
                        %test = "END AUCTION"
                        
                        
                        %Determine winner (the bid with the highest fuel saved over delay mutiplied 
                        %with the division) (Only if there is a bid, else
                        %no formation is formed
                        if isempty(Bids) == 0
                            bestBid = max(Bids(:,2));
                            Bidnumber=find(Bids(:,2)==bestBid);
                            acNr2 = Bids(Bidnumber(1),1);

                            %Form formation
                            step1b_routingSynchronizationFuelSavings;
                            fuelSavingsOffer = Bids(Bidnumber(1),2)*timeAdded_acNr1;
                            divisionFutureSavings=Bids(Bidnumber(1),3);
                            step1c_updateProperties
                        end

                        %End the auction
                        auction = 0;
                        break

                end
            end 
        end
    end           
end