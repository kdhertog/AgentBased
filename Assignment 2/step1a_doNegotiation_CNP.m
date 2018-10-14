%% step1a_doNegotiation_CNP.m description
% Add your CNP agent models and edit this file to create your CNP. 

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

%----Parameters that need to be added-----

    %Constant used for waying if agent i has enough max_delay left to
    %become a manager. This can be bigger than 0. 
    managerDelayDecision = 0;
    
    %A penalty is needed in reward is needed if a alliance member bids as a
    %contractor on a non-allaince manager
    noAlliancePenatly=0.8;
    
    %The percentage of the best solution at which the agent will decided
    %tom make in bid in the current round
    bidratio=0.8;
    
    %Fuel save over delay  for alliance flights when they only want to
    %fly together with alliance partners
    FuelRatioAlliance=40;
    
    %Fuel save over delay for any combination between allaince flights and
    %non-allaince flights. This is ratio is also used for all contractors
    FuelRatioNonAlliance=30;
    
    %Create an array with each aircraft and how many possible communication
    %partners there are for each aircraft. The one with most possible
    %connection is selected as first for manager. 
    NumberofCandidates=[];
    for i = 1:length(communicationCandidates(:,1)) 
        NumberofCandidates=[NumberofCandidates;communicationCandidates(i,1),nnz(communicationCandidates(i,2:end))];
    end
    Managerorder=sortrows(NumberofCandidates,2,'descend');
    

for i = 1:length(communicationCandidates(:,1))     
    % Store flight ID of flight i in variable.
    acNr1 = Managerorder(i,1);     
    
    % Determine the number of communication candidates for flight i.
    nCandidates = Managerorder(i,2); 
    
    %----THIS BLOCK OF CODE IS ADDED----

    %Bids for each contractor are stored in the following list. The first
    %entry is the flight ID, second is the fuel saved over delay mutiplied 
    %times the division. Third is the devision ratio for acNr1 w.r.t. the 
    %total earnings. The fourht parameter determines if the bid comes from 
    %the alliance or not.
    Bids=[];
    
    %Check if the aircraft is able to communicate, if it has candidates to
    %communicate with, and if it can have additional delay. 
    if flightsData(acNr1,2) == 1 && nCandidates > 0 && ...
            flightsData(acNr1,26) > managerDelayDecision
            
        %Agent becomes manager, so the CNP agent file is called, depending
        %on if the flight is in the alliance or not. If the agent does not
        %become manager, nothing else is done. 
            
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
        IndexacNr1=find(communicationCandidates(:,1)==acNr1);
        
        for j = 1:nCandidates
            acNr2=communicationCandidates(IndexacNr1,j+1);
            
            %Determine if acNr2 & acNr1 are still available for communication
            if flightsData(acNr2,2) == 1 && flightsData(acNr1,2) == 1
                
                %Determine if the formation leader of acNr2 is part of the allaince or not
                %This is checked by looking at all aircraft with the
                %same coordinates.
                if flightsData(acNr2,17) == 1          
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
                
                % If the manager is not part of the allaince the bid of the
                % contractor depends on the fact if it is part of the
                % alliance or not. 
                if AllianceacNr1==1                    
                    step1b_routingSynchronizationFuelSavings
                    if potentialFuelSavings > 0
                        %If the manager is part not part of the allaince,
                        %the behaviour of the contractors differs for
                        %alliance and non alliance members
                        if AllianceacNr2==1
                        %Bid of acNr2 if it is a non alliance member
                            FuelDelayRatio=potentialFuelSavings/ ...
                                (timeAdded_acNr1+timeAdded_acNr2);
                            devision=timeAdded_acNr1/(timeAdded_acNr1+timeAdded_acNr2);
                            %Update the best fuel saving option for each
                            %aircraft.
                            if FuelDelayRatio*(1-devision)>flightsData(acNr2,30)
                               flightsData(acNr2,30)= FuelDelayRatio*(1-devision);
                            end
  
                            if ~isempty(flightsData(acNr2,29)) && ...
                                    FuelDelayRatio*(1-devision)>bidratio* ...
                                    flightsData(acNr2,29)
                                Bids=[Bids;acNr2,FuelDelayRatio*devision ...
                                ,devision,AllianceacNr2];
                            end                            
                        else
                        %If acNr2 is part of the alliance it is less
                        %willing to cooporate with a non alliance member
                        %therefore a penalty value is added. 
                            FuelDelayRatio=potentialFuelSavings/ ...
                                (timeAdded_acNr1+timeAdded_acNr2);
                            devision=timeAdded_acNr1/(timeAdded_acNr1+timeAdded_acNr2)*...
                                noAlliancePenatly;
                            if FuelDelayRatio*(1-devision)>flightsData(acNr2,30)
                               flightsData(acNr2,30)= FuelDelayRatio*(1-devision);
                            end
  
                            if ~isempty(flightsData(acNr2,29)) && ...
                                    FuelDelayRatio*(1-devision)>bidratio* ...
                                    flightsData(acNr2,29)
                                Bids=[Bids;acNr2,FuelDelayRatio*devision ...
                                ,devision,AllianceacNr2];
                            end 
                        end
                    end
                else 
                    %If the manager is an alliance member the bid does not
                    %depend on the fact if the contractor is part of the
                    %alliance or not
                    
                    step1b_routingSynchronizationFuelSavings
                    
                    if potentialFuelSavings > 0
                        FuelDelayRatio=potentialFuelSavings/ ...
                            (timeAdded_acNr1+timeAdded_acNr2);
                        devision=timeAdded_acNr1/(timeAdded_acNr1+timeAdded_acNr2);
                        if FuelDelayRatio*(1-devision)>flightsData(acNr2,30)
                           flightsData(acNr2,30)= FuelDelayRatio*(1-devision);
                        end

                        if ~isempty(flightsData(acNr2,29)) && ...
                                FuelDelayRatio*(1-devision)>bidratio* ...
                                flightsData(acNr2,29)
                            Bids=[Bids;acNr2,FuelDelayRatio*devision ...
                            ,devision,AllianceacNr2];
                        end 
                    end
                end

                
            end
        end

        if  isempty(Bids)==0
            %Find the best bid that the contractor received in terms of
            %fuel save over delay ratio. 
            BestBid=max(Bids(:,2))
            Bidnumber=find(Bids(:,2)==BestBid);
            
            % If acNr1 is part of the alliance, a distinction is made
            % between bids from allaince flight and non alliance
            if AllianceacNr1==2
                %Create a list with all the elements that come from the
                %allaince
                AllianceBids=Bids(Bids(:,4)==2,:);
                BestAllianceBid=max(AllianceBids(:,2));
                BidnumberAlliance=find(AllianceBids(:,2)==BestAllianceBid);
                % The program checks if there are bids from alliance
                % partners. If not it inmediately starts to consider all
                % other bids
                if ~isempty(AllianceBids) && ...
                        AllianceBids(BidnumberAlliance(1),2)>FuelRatioAlliance
                    acNr2=Bids(BidnumberAlliance(1),1);
                    step1b_routingSynchronizationFuelSavings;
                    fuelSavingsOffer = AllianceBids(BidnumberAlliance(1),2)*timeAdded_acNr1;
                    divisionFutureSavings=AllianceBids(BidnumberAlliance(1),3);
                else
                    % If the bids from alliance members are not good
                    % enough bids from non alliance partners are also
                    % considered. 
                    if Bids(Bidnumber(1),2)>FuelRatioNonAlliance
                        acNr2=Bids(Bidnumber(1),1);
                        step1b_routingSynchronizationFuelSavings;
                        fuelSavingsOffer = Bids(Bidnumber(1),2)*timeAdded_acNr1;
                        divisionFutureSavings=Bids(Bidnumber(1),3);
                    end
                end
                
            else
                %If the manager is not part of the alliance is does not
                %matter if the bids come from the alliance or from non
                %allaince partners. 
                if Bids(Bidnumber(1),2)>FuelRatioNonAlliance
                    acNr2=Bids(Bidnumber(1),1);
                    step1b_routingSynchronizationFuelSavings;
                    fuelSavingsOffer = Bids(Bidnumber(1),2)*timeAdded_acNr1;
                    divisionFutureSavings=Bids(Bidnumber(1),3);
                end
            end
            % Update the relevant flight properties for the formation
            % that is accepted.
            step1c_updateProperties
        end 
    end   
end

%Move the bids from the current round to the flight property of bids from
%the previous round. At next time step the CNP protocol will be called
%again and theb the contractors will use their bids from the previous round
%to make their new bids
flightsData(:,29)=flightsData(:,30);
flightsData(:,30)=0;


