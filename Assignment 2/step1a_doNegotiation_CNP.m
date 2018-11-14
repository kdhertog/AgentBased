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
noAlliancePenalty=0.5;

%The percentage of the best solution at which the agent will decided
%tom make in bid in the current round
bidratio=0.8;

%Fuel save over delay  for alliance flights when they only want to
%fly together with alliance partners
FuelRatioAlliance=175;

%Fuel save over delay for any combination between allaince flights and
%non-allaince flights. This is ratio is also used for all contractors
FuelRatioNonAlliance=78.75;
 
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
        
        if coordination==1
            AlliancePartners=[];
            NonAlliancePartners=[];
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
                
               
                if AllianceacNr2==2 && coordination==1
                    AlliancePartners=[AlliancePartners, acNr2];
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
                            %aircraft for the current time step
                            if FuelDelayRatio*(1-devision)>flightsData(acNr2,30)
                               flightsData(acNr2,30)= FuelDelayRatio*(1-devision);
                            end
                               % If there the list op possible bids from
                               % the previous round is not empy then the
                               % fuel delay ration should be higher 80% of
                               % the best bid of the previous round in
                               % order to make a bid
                            if ~isempty(flightsData(acNr2,29)) && ...
                                    FuelDelayRatio*(1-devision)>bidratio* ...
                                    flightsData(acNr2,29)
                                % The alliance partners would like to know
                                % how many non alliance partners made a bid
                                if coordination==1 
                                    NonAlliancePartners=[NonAlliancePartners, acNr2];
                                end
                                %The bids includes the flight number, fuel
                                %delay ratio*devision, the devision, and
                                %the alliance of the bidder
                                Bids=[Bids;acNr2,FuelDelayRatio*devision ...
                                ,devision,AllianceacNr2];
                            end                            
                        else
                        %If acNr2 is part of the alliance it is less
                        %willing to cooporate with a non alliance member
                        %therefore a penalty value is added. 
                            FuelDelayRatio=potentialFuelSavings/ ...
                                (timeAdded_acNr1+timeAdded_acNr2);
                            %A non alliance penalty is added to the
                            %devision iif the manager is not part of the
                            %alliance and if the contractor is member, 
                            devision=timeAdded_acNr1/(timeAdded_acNr1+timeAdded_acNr2)*...
                                noAlliancePenalty;
                            if FuelDelayRatio*(1-devision)>flightsData(acNr2,30)
                               flightsData(acNr2,30)= FuelDelayRatio*(1-devision);
                            end
                           % If there the list op possible bids from
                           % the previous round is not empy then the
                           % fuel delay ration should be higher 80% of
                           % the best bid of the previous round in
                           % order to make a bid
                            if ~isempty(flightsData(acNr2,29)) && ...
                                    FuelDelayRatio*(1-devision)>bidratio* ...
                                    flightsData(acNr2,29)
                                %The bids includes the flight number, fuel
                                %delay ratio*devision, the devision, and
                                %the alliance of the bidder
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
                           % If there the list op possible bids from
                           % the previous round is not empy then the
                           % fuel delay ration should be higher 80% of
                           % the best bid of the previous round in
                           % order to make a bid    
                        if ~isempty(flightsData(acNr2,29)) && ...
                                FuelDelayRatio*(1-devision)>bidratio* ...
                                flightsData(acNr2,29)
                            % The alliance partners would like to know
                            % how many non alliance partners made a bid
                            if coordination==1 && AllianceacNr2==1
                                    NonAlliancePartners=[NonAlliancePartners, acNr2];
                            end
                            %The bids includes the flight number, fuel
                            %delay ratio*devision, the devision, and
                            %the alliance of the bidder
                            Bids=[Bids;acNr2,FuelDelayRatio*devision ...
                            ,devision,AllianceacNr2];
                            
                        end 
                    end
                end
            end
        end
        %If coordination is applied and the non alliance manager has more than 1
        %alliance contractor, then  all of the possible formations between
        %contracotrs is evaluated as well. If two allaince flight can
        %achieve a better fuel delay ratio together then by forming a
        %formation with the non alliance mamanger, then they will delete
        %their bid. 
        if AllianceacNr1==1 && coordination==1 && ...
                length(AlliancePartners)>=2 && isempty(Bids)==0
            %The flight number of the manager need to be temporarily saved
            %because this is required for step1b and step1c
            acNr1Original=acNr1;
            AllianceCoordination=[];
            
            for Coordination1= 1:length(AlliancePartners)-1
                acNr1=AlliancePartners(Coordination1);
                for Coordination2= Coordination1+1:length(AlliancePartners)
                    acNr2=AlliancePartners(Coordination2);
                    step1b_routingSynchronizationFuelSavings
                    % If the fuel savings are positive, then this bid is
                    % saved and taken into consideration bby the manager
                    if potentialFuelSavings>0
                        FuelDelayRatio=potentialFuelSavings/ ...
                            (timeAdded_acNr1+timeAdded_acNr2);
                        acNr1Bid=find(Bids(:,1)==acNr1);
                        acNr2Bid=find(Bids(:,1)==acNr2);
                        % If aircraft acNr1 publsiehd a bisd for the
                        % mamanger, it is compared to to the fuel delay
                        % ratio which can be acheived with the alliance
                        % partner. 
                        if isempty(acNr1Bid)==0
                            fuelSaveRatioBid=Bids(acNr1Bid,2)/Bids(acNr1Bid,3) ...
                                *(1-Bids(acNr1Bid,3));
                            fuelSaveRatioAlliance=FuelDelayRatio*timeAdded_acNr1 / ...
                                (timeAdded_acNr1+timeAdded_acNr2);
                            % If you can achieve a higher fuel delay
                            % ratio with the lliance partner the contractor
                            % will delete the bid for manager. 
                            if fuelSaveRatioAlliance>fuelSaveRatioBid
                                Bids(acNr1Bid,2)=0;
                                disp("Bid deleted");
                                CoordinationCount1=CoordinationCount1+1;
                            end
                        end
                        % Same procdure as above but then for acNr2
                        if isempty(acNr2Bid)==0
                            fuelSaveRatioBid=Bids(acNr2Bid,2)/Bids(acNr2Bid,3) ...
                                *(1-Bids(acNr2Bid,3));
                            fuelSaveRatioAlliance=FuelDelayRatio*timeAdded_acNr2 / ...
                                (timeAdded_acNr1+timeAdded_acNr2);
                            if fuelSaveRatioAlliance>fuelSaveRatioBid
                                Bids(acNr2Bid,2)=0;
                                disp("Bid deleted");
                                CoordinationCount1=CoordinationCount1+1;
                            end
                        end
                    end
                end
            end
            %Restore back the original value for acNr1
            acNr1=acNr1Original;
        end
        
        %If the coordination is applied, and no non alliance flight has
        %published a bid then only the best alliance flight will remain as
        %bidder and will bid just above FuelRatioNonAlliance, so most of
        %the benefits are for the alliance contracotr. Note: it does not 
        %matter if the manager is part of the alliance or not 
        if coordination==1 && isempty(NonAlliancePartners) && ...
                ~isempty(Bids) && min(Bids(:,3)>0)
            BestBid=find(Bids(:,2)/Bids(:,3)==max((Bids(:,2)/Bids(:,3))));
            BestBid=BestBid(1);
            %Check if the best bid is good enough to form a fomration
            if Bids(BestBid,2)>FuelRatioNonAlliance
                FuelDelayRatio=Bids(BestBid,2)/Bids(BestBid,3);
                Devision=(FuelRatioNonAlliance+0.01)/FuelDelayRatio;
                %The onlty bid that remains is the best of the best
                %contractor
                Bids=[Bids(BestBid,1) (FuelRatioNonAlliance+0.01) Devision Bids(BestBid,4)];
                CoordinationCount2=CoordinationCount2+1;
            end
        end
        

        if  isempty(Bids)==0
            %Find the best bid that the contractor received in terms of
            %fuel save over delay ratio. 
            BestBid=max(Bids(:,2));
            Bidnumber=find(Bids(:,2)==BestBid);
            
            % If acNr1 is part of the alliance, a distinction is made
            % between bids from allaince flight and non alliance
            if AllianceacNr1==2
                % If coordination is applied, the mamanger is part of
                % the alliance, and there are at least two alliance
                % contracotrs then all of the possible inner formations
                % between contrqactoors are evaluated 
                if coordination==1 && length(AlliancePartners)>=2
                    acNr1Original=acNr1;
                    AllianceCoordination=[];
                    for Coordination1= 1:length(AlliancePartners)-1
                        acNr1=AlliancePartners(Coordination1);
                        for Coordination2= Coordination1+1:length(AlliancePartners)
                            acNr2=AlliancePartners(Coordination2);
                            step1b_routingSynchronizationFuelSavings
                            if potentialFuelSavings>0
                                FuelDelayRatio=potentialFuelSavings/ ...
                                    (timeAdded_acNr1+timeAdded_acNr2);
                                AllianceCoordination=[AllianceCoordination; ...
                                    acNr1 acNr2 FuelDelayRatio];
                            end
                        end
                    end
                    %The best best possible combination between contractors
                    %is decided based on the max fuel delay ratio. 
                    if ~isempty(AllianceCoordination)
                        BestCoordination=max(AllianceCoordination(:,3));
                        BidnumberCoordination=find(AllianceCoordination(:,3)==...
                            BestCoordination);
                        AllianceacNr1=AllianceCoordination(BidnumberCoordination,1);
                        AllianceacNr2=AllianceCoordination(BidnumberCoordination,2);
                    else
                        % If there are no possible combinations between the
                        % contractyors, then Best coordination is set to 0.
                        BestCoordination=0;
                    end
                    acNr1=acNr1Original;
                else
                    BestCoordination=0;
                end
                
                %Create a list with all the elements that come from the
                %allaince
                AllianceBids=Bids(Bids(:,4)==2,:);
                BestAllianceBid=max(AllianceBids(:,2));
                BidnumberAlliance=find(AllianceBids(:,2)==BestAllianceBid);
                % The program checks if there are bids from alliance
                % partners. If not it inmediately starts to consider all
                % other bids
                
                %If a formation between two alliance contracotrs is bettter
                %then these two contracotrs should form a formation
                if coordination==1 &&~isempty(AllianceBids) && ...
                        BestCoordination>2*AllianceBids(BidnumberAlliance(1),2) ...
                        && BestCoordination>2*FuelRatioAlliance
                    disp("Coordination 1 applied");
                    CoordinationCount3=CoordinationCount3+1;
                    acNr1=AllianceacNr1;
                    acNr2=AllianceacNr2;
                    step1b_routingSynchronizationFuelSavings;
                    fuelSavingsOffer = potentialFuelSavings* ...
                        timeAdded_acNr1 / (timeAdded_acNr1+ ...
                        timeAdded_acNr2+1e-8);
                    divisionFutureSavings=timeAdded_acNr1 / ...
                        (timeAdded_acNr1+ timeAdded_acNr2+1e-8);
                    step1c_updateProperties
                % Else the bids form alloaince contractors to the alliance
                % manager are considered
                elseif ~isempty(AllianceBids) && ...
                        AllianceBids(BidnumberAlliance(1),2)>FuelRatioAlliance
                    acNr2=AllianceBids(BidnumberAlliance(1),1);
                    step1b_routingSynchronizationFuelSavings;
                    fuelSavingsOffer = potentialFuelSavings*...
                        AllianceBids(BidnumberAlliance(1),3);
                    divisionFutureSavings=AllianceBids(BidnumberAlliance(1),3);
                    step1c_updateProperties
                else
                    % If the bids from alliance members are not good
                    % enough bids from non alliance partners are also
                    % considered.
                    
                    %If a formation between two alliance contractors is
                    %better than a formation wit a non alliance contractor,
                    %then the two alliance contracotrs form a formation. 
                    if coordination==1 && BestCoordination > ...
                            2*Bids(Bidnumber(1),2) && BestCoordination > ...
                            2*FuelRatioNonAlliance
                        disp("Coordination 2 applied");
                        CoordinationCount3=CoordinationCount3+1;
                        acNr1=AllianceacNr1;
                        acNr2=AllianceacNr2;
                        step1b_routingSynchronizationFuelSavings;
                        fuelSavingsOffer = potentialFuelSavings* ...
                            timeAdded_acNr1 / (timeAdded_acNr1+ ...
                            timeAdded_acNr2+1e-8);
                        divisionFutureSavings=timeAdded_acNr1 / ...
                            (timeAdded_acNr1+ timeAdded_acNr2+1e-8);
                        step1c_updateProperties
                    %The last option of the alliance manager is to consider all bids   
                    elseif Bids(Bidnumber(1),2)>FuelRatioNonAlliance
                        acNr2=Bids(Bidnumber(1),1);
                        step1b_routingSynchronizationFuelSavings;
                        fuelSavingsOffer = potentialFuelSavings*...
                            Bids(Bidnumber(1),3);
                        divisionFutureSavings=Bids(Bidnumber(1),3);
                        step1c_updateProperties
                    end
                end
                
            else
                %If the manager is not part of the alliance is does not
                %matter if the bids come from the alliance or from non
                %allaince partners. 
                if Bids(Bidnumber(1),2)>FuelRatioNonAlliance
                    acNr2=Bids(Bidnumber(1),1);
                    step1b_routingSynchronizationFuelSavings;
                    fuelSavingsOffer = potentialFuelSavings*...
                    Bids(Bidnumber(1),3);
                    divisionFutureSavings=Bids(Bidnumber(1),3);
                    step1c_updateProperties
                end
            end
            % Update the relevant flight properties for the formation
            % that is accepted.
        end 
    end   
end

%Move the bids from the current round to the flight property of bids from
%the previous round. At next time step the CNP protocol will be called
%again and theb the contractors will use their bids from the previous round
%to make their new bids
flightsData(:,29)=flightsData(:,30);
flightsData(:,30)=0;


