// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CharityContract {

//_____________________________________________________________________________

    // SECTION: Storage Variable

    address public ownerAddress;

    address payable public charityAddress;

    bool public contractIsActive = true;

//_____________________________________________________________________________

    // SECTION: Custom Errors and Function Modifiers

    error CharityContract__CallerIsNotOwner();
    modifier onlyOwner() {
        if (msg.sender != ownerAddress) {
            revert CharityContract__CallerIsNotOwner();
        }
        _;
    }

    error CharityContract__ContractIsInactive();
    modifier onlyActive() {
        if (contractIsActive != true) {
            revert CharityContract__ContractIsInactive();
        }
        _;
    }

    error CharityContract__DonationToContractFailed();
    error CharityContract__SendingBalanceToCharityFailed();

//_____________________________________________________________________________

    // SECTION: Events

    event ContractDeactivated();

    event DonationMadeToContract(uint256 valueOfDonation, address addressOfSender);

//_____________________________________________________________________________

    constructor(address payable _charityAddress) {
        
        ownerAddress = msg.sender;

        charityAddress = _charityAddress;

    }
    
    //_________________________________________________________________________

    // SECTION: Function 1
    
    receive() payable external onlyActive {}
    
    //_________________________________________________________________________
  
    // SECTION: Function 2
    
    function DonateToContract() payable public onlyActive {

        (bool success, /* bytes memory data */) =
            address(this).call{ value: msg.value }("");

        if (!success) {
            revert CharityContract__DonationToContractFailed();
        }

        emit DonationMadeToContract(msg.value, msg.sender);
         
    }

    //_________________________________________________________________________

    // SECTION: Function 3

    function finalizeCharityCollection() public onlyOwner onlyActive {

        uint256 contractBalance = address(this).balance;

        (bool success, /* bytes memory data */) =
            charityAddress.call{ value: contractBalance }("");

        if (!success) {
            revert CharityContract__SendingBalanceToCharityFailed();
        }

        assert(contractBalance == 0);

        contractIsActive = false;

        emit ContractDeactivated();

    }
    
    //_________________________________________________________________________

}
