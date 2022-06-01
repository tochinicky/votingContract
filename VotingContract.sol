//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 < 0.9.0;
import "./IVotingContract.sol";

contract VotingContract is IVotingContract
{
    address public owner;
    uint registeredTime;
     mapping(address => Candidate) public candidateLookup;
     Candidate[] public candidate;
     uint public candidateCount;// Keeps a track of the number of candidates and also fulfills the function to generate a unique ID
    mapping(address => bool) public voterlookup;
    mapping(address => bool) public exist;
    struct Candidate {
        address id;   // short name (up to 32 bytes)
        uint voteCount; 
        bytes32 name;
    }
    constructor(){
        owner = msg.sender;
        registeredTime = block.timestamp;
    }
    event votedEvent(address _candidateId, uint votecount);
    event candidateEvent(Candidate[]);

    function addCandidate(address candidateAddr,string memory name) override external returns(bool) {
        require(bytes(name).length != 0,"invalid input");
        require(msg.sender == owner,"you are not the owner");
        require(candidateAddr != owner,"you can't be a candidate");
        require(!exist[candidateAddr],"candidate already existed");
        require(block.timestamp <= registeredTime + 180, "unable to add candidate");
        bytes32 nameToByte = stringToBytes32(name);
        
        candidate.push(Candidate({id:candidateAddr, voteCount:0, name:nameToByte}));
        candidateCount++;
         emit candidateEvent(candidate);
       return exist[candidateAddr] = true;
        //return userAdded;
    }

    function voteCandidate(address candidateId) override external returns(bool){
         require(block.timestamp <= registeredTime + 360, "voting closed at the moment");
        
        // require that they haven't voted before
        require(!voterlookup[msg.sender],"you've voted already!!!");
         // record that voter has voted
        voterlookup[msg.sender] = true;
        
         // update candidate vote Count
      
           candidateLookup[candidateId].voteCount++;
           
            // trigger voted event 0x17F6AD8Ef982297579C203069C1DbfFE4348c372
           emit votedEvent(candidateId,candidateLookup[candidateId].voteCount);
              emit candidateEvent(candidate);
           return true;

        
    }
     function getWinner() override external  returns(bytes32){
       bytes32 winnerName_ = candidate[winningProposal()].name;
       //string memory winner = bytesToString(winnerName_);
       return winnerName_;
     }
     function winningProposal() private 
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < candidate.length; p++) {
            if (candidate[p].voteCount > winningVoteCount) {
                winningVoteCount = candidate[p].voteCount;
                winningProposal_ = p;
            }
        }
        emit candidateEvent(candidate);
    }
   
    function stringToBytes32(string memory source) private pure returns (bytes32 result) 
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
    function bytesToString(bytes32 name) public pure returns(string memory){
        uint8 i =0;
        while(i < 32 && name[i] != 0 ){
                 
            i++;
        }
        bytes memory anotherName =  new bytes(i);
        for(i = 0; i < 32 && name[i] != 0; i++){

            anotherName[i] = name[i];
        }
        return string(anotherName);

    }
}
