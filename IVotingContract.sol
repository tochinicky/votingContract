// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface IVotingContract{

//only one address should be able to add candidates
    function addCandidate(address candidateAddr,string memory _candidateName) external returns(bool);

    
    function voteCandidate(address candidateId) external returns(bool);

    //getWinner returns the name of the winner
    function getWinner() external returns(bytes32);
}
