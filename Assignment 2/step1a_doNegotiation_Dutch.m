%% step1a_doNegotiation_Dutch.m description
% Add your Dutch agent models and edit this file to create your Dutch
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

%Minimum fuel savings for both the auctioneer and the bidder
fuelSaveRequired = 100;

%Factor to lower the private value of an alliance bidder in case of a
%non-alliance auctioneer
factorNonAllianceAuctioneer = 0.8;

%Starting bid height of the auction
initialBidHeight = 5000;

%Create an array with each aircraft and how many possible communication
%partners there are for each aircraft. The one with most possible
%connection is selected as first for auctioneer. 
NumberofCandidates=[];
for i = 1:length(communicationCandidates(:,1)) 
    NumberofCandidates=[NumberofCandidates;communicationCandidates(i,1),nnz(communicationCandidates(i,2:end))]; %#ok<AGROW>
end
Auctioneerorder=sortrows(NumberofCandidates,2,'descend');

%Loop over all potential auctioneers
for i = 1:length(communicationCandidates(:,1))     
    % Store flight ID of flight i in variable.
    acNr1 = Auctioneerorder(i,1);    
    
    % Determine the number of communication candidates for flight i.
    nCandidates = Auctioneerorder(i,2); 
    
    %Bids for each auction are stored in the following list. The first
    %entry is the flight ID, second is the potential fuel savings mutiplied 
    %by the division. Third is the devision ratio for acNr1 w.r.t. the 
    %total earnings. The fourth parameter determines if the bid comes from 
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
            
            % Check if there are two alliance members in the auction for
            % coordination. 
            AllianceCoordination=[];
            if coordination==1 && nBidders>2
                alliancePartners=[];
                
                for j = 1:nBidders
                    acNr2 = bidders(j+1);
                    IndexacNr2 = find(bidders==acNr2);
                    
                    %Determine if acNr2 & acNr1 are still available for
                    %communication BUG FIX FROM BS FORUM (%if
                    %flightsData(acNr2,2) == 1 && flightsData(acNr1,2) == 1)
                    if flightsData(acNr1,2) == 1 && flightsData(acNr2,2) == 1 && ...
                    (flightsData(acNr1,14) ~= flightsData(acNr2,14) &&  flightsData(acNr1,15) ~= flightsData(acNr2,15))

                        %Determine if the formation leader of acNr2 is part of the alliance or not
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
                        
                        %if the aircraft is part of the alliance they get
                        %added to the list
                        if AllianceacNr2==2
                            alliancePartners=[alliancePartners, acNr2]; %#ok<AGROW>
                        end
                    end
                end
                
                % If coordination is applied and there are more than two
                % alliance partners participating in the bidding process
                % they are also checking all the possible internal
                % combination. 
                if coordination==1 && length(alliancePartners(:))>1
                    acNr1Original=acNr1;
                    
                    for Coordination1= 1:length(alliancePartners)-1
                        acNr1=alliancePartners(Coordination1);
                        
                        for Coordination2= Coordination1+1:length(alliancePartners)
                            acNr2=alliancePartners(Coordination2);
                            
                            step1b_routingSynchronizationFuelSavings
                            
                            % If two aircraft can have a positive fuel
                            % saving this gets added to the list
                            % alliance coordination. In the list each
                            % aircraft with a positive potential fuel
                            % saving is listen together with their ac
                            % number. 
                            if potentialFuelSavings>0
                                if ~isempty(AllianceCoordination)
                                    acNr1index=find(AllianceCoordination(:,1)==acNr1);
                                    acNr2index=find(AllianceCoordination(:,1)==acNr2);
                                else 
                                    acNr1index=[];
                                    acNr2index=[];
                                end
                                
                                if isempty(acNr1index)
                                    AllianceCoordination=[AllianceCoordination; ...
                                    acNr1 0.5*potentialFuelSavings]; %#ok<AGROW>
                                elseif AllianceCoordination(acNr1index,2)<0.75*potentialFuelSavings
                                    AllianceCoordination(acNr1index,2)= ...
                                        0.5*potentialFuelSavings;
                                end
                                
                                if isempty(acNr2index)
                                    AllianceCoordination=[AllianceCoordination; ...
                                    acNr2 0.5*potentialFuelSavings]; %#ok<AGROW>
                                elseif AllianceCoordination(acNr2index,2)<0.75*potentialFuelSavings
                                    AllianceCoordination(acNr2index,2) = ...
                                       0.5*potentialFuelSavings;
                                end
                            end
                        end
                    end
                    
                    %Restore the value of the acNr1 to the auctioneer
                    acNr1=acNr1Original;
                end
            end
            
            %Start the auction
            bidHeight = initialBidHeight;
            non_alliance = 0; %if there are any non-alliance bidders
            
            while bidHeight > fuelSaveRequired-10
                
                if nBidders < 1
                    test = "BREAK";
                    break
                end
                
                %Set up list for bookkeeping
                BiddersToBeRemoved = []; %Bidders that do not want to bid anymore
                alliancePotentialFuelSavings = []; %potential fuel savings of alliance members
                %Loop over all bidders
                for j = 1:nBidders
                    acNr2 = bidders(j+1);
                    IndexacNr2 = find(bidders==acNr2);

                    %Determine if acNr2 & acNr1 are still available for
                    %communication BUG FIX FROM BS FORUM (%if
                    %flightsData(acNr2,2) == 1 && flightsData(acNr1,2) == 1)
                    if flightsData(acNr1,2) == 1 && flightsData(acNr2,2) == 1 && ...
                    (flightsData(acNr1,14) ~= flightsData(acNr2,14) &&  flightsData(acNr1,15) ~= flightsData(acNr2,15))

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
                        
                        %If the bidder is alliance we want to store the
                        %fuel savings, to enable coordination
                        if AllianceacNr2 == 2 && potentialFuelSavings > 0  
                            test = "ALLIANCE";
                            alliancePotentialFuelSavings = [alliancePotentialFuelSavings, [IndexacNr2, potentialFuelSavings]]; %#ok<AGROW>
                        elseif AllianceacNr2 == 1 
                            non_alliance = 1;
                        end
                        
                        %Determine to bid or not. If there is a potential for
                        %FuelSavings, the agent wants to bid. 
                        bidDecisionFactor = potentialFuelSavings;
                        bidTreshold = 0; %bidDecision factor should be bigger than this
                        if bidDecisionFactor > bidTreshold
                                
                                %determine private value
                                if AllianceacNr1 == 2 && AllianceacNr2 == 2 %Both are in the alliance, so they want to work together no matter what
                                    privateValue = 1.0;
                                    test = "OPTION1";
                                elseif AllianceacNr1 == 1 && AllianceacNr2 == 2 %Alliance bidder has a lower willingness to work with non alliance 
                                    privateValue = (1 - fuelSaveRequired / potentialFuelSavings) * factorNonAllianceAuctioneer;
                                    test = "OPTION2";
                                else
                                    privateValue = 1 - fuelSaveRequired / potentialFuelSavings;
                                    test = "OPTION4";
                                end
                                
                                %Determine devision required to make the bid
                                devision = bidHeight / potentialFuelSavings;

                                %If the agent can bid he bids
                                bidValue = devision;
                                
                                %Check if the aircraft has other
                                %possibilities to cooperate with other
                                %allaince members
                                if ~isempty(AllianceCoordination)
                                    acNr2CoordinationIndex=find(AllianceCoordination(:,1)==acNr2);
                                else 
                                    acNr2CoordinationIndex=[];
                                end
                                
                                %If the aircraft can get a higher fuel
                                %saving with other agent, the agent stops
                                %bidding
                                if coordination==1 && ~isempty(acNr2CoordinationIndex) && ...
                                      (1-bidValue)*potentialFuelSavings < ...
                                      AllianceCoordination(acNr2CoordinationIndex,2)   
                                        test="Coordination applied";
                                      BiddersToBeRemoved = [BiddersToBeRemoved,IndexacNr2]; %#ok<AGROW> 
                                
                                elseif bidValue <= privateValue
                                    test = "BID";
                                    %add bid to Bids
                                    %Check again if the flights are able to communicate
                                    if flightsData(acNr1,2) == 1 && flightsData(acNr2,2) == 1 && ...
                                        (flightsData(acNr1,14) ~= flightsData(acNr2,14) &&  flightsData(acNr1,15) ~= flightsData(acNr2,15))
                                        fuelSavingsOffer = potentialFuelSavings*devision;
                                        divisionFutureSavings = devision;
                                        step1c_updateProperties
                                    
                                    %end the auction
                                    bidHeight = -1;
                                    break
                                    end
                                end
                        else
                                %The agent does not want to bid, so he gets
                                %removed from the collection of bidders
                                test = "REMOVE BIDDER2";
                                BiddersToBeRemoved = [BiddersToBeRemoved,IndexacNr2]; %#ok<AGROW>
                        end
                        
                    else
                        %The agent is not able to communicate, so he gets
                        %removed from the collection of bidders
                        test = "REMOVE BIDDER3";
                        BiddersToBeRemoved = [BiddersToBeRemoved,IndexacNr2]; %#ok<AGROW>
                    end
                    
                end
                
                %When there are only alliance bidders, only the alliance
                %aircraft with the highest potential fuel savings will
                %stay. Since this is then the only bidder, the auction will
                %ends when this agent bids, which will be at the minimum
                %value. So the auction will end, with the minimum as the
                %winning bid. 
                if coordination == 1 && isempty(alliancePotentialFuelSavings) == 0 && non_alliance == 0
                    test = "Coordination";
                    maxAlliance = max(alliancePotentialFuelSavings(:,2));
                    IndexmaxAlliance = find(alliancePotentialFuelSavings(:,2)==maxAlliance);
                    IndexacNr2 = alliancePotentialFuelSavings(IndexmaxAlliance(1),1);
                    acNr2 = bidders(IndexacNr2);
                    
                    %Check again if the flights are able to communicate
                    if flightsData(acNr1,2) == 1 && flightsData(acNr2,2) == 1 && ...
                    (flightsData(acNr1,14) ~= flightsData(acNr2,14) &&  flightsData(acNr1,15) ~= flightsData(acNr2,15))
                        step1b_routingSynchronizationFuelSavings;
                        devision = fuelSaveRequired / potentialFuelSavings;
                        fuelSavingsOffer = potentialFuelSavings*devision;
                        divisionFutureSavings = devision;
                        step1c_updateProperties
                      
                        %end the auction
                        bidHeight = -1000;
                        break
                    end
                    
                end
                
                %Remove bidders from the bidder list
                bidders(BiddersToBeRemoved) = [];
                nBidders = length(bidders)-1;
                
                %Lower bid height
                bidHeight = bidHeight * 0.95;
            end 
        end
    end           
end


