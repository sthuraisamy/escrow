pragma solidity ^0.4.18;

contract Escrow {
    address public buyer;
    address public seller;
    uint public timeToExpiry;
    uint public timeToReturn;
    uint public startTime;
    uint public receivedTime;
    uint public deposit;
    string public status;

    //Buyer initiate the the escrow contract and make deposit
    function Escrow(address _seller, uint _timeToExpiry, uint _timeToReturn) public payable {
        buyer = msg.sender;
        seller = _seller;
        deposit = msg.value;
        timeToExpiry = _timeToExpiry;
        timeToReturn = _timeToReturn;
        startTime = now;
        status = "Escrow Setup";
    }

    //Seller process teh shipment
    function itemShipped(string _status) public {
        if (msg.sender == seller) {
            status = _status;
        } else {
            revert(); 
        }
    }

    //On receiving the item the buyer releases the 25% deposit to seller
    function itemReceived(string _status) public {
        if (msg.sender == buyer) {
            status = _status;
            receivedTime = now;

            if (!seller.send(deposit/4)) {
                revert();
            }
        } else {
            revert();
        }
    }

    //Buyer releases balance deposit to seller and finishes teh contract
    function releaseBalanceToSeller() public {
        if (msg.sender == buyer) {
            selfdestruct(seller);  
        } else {
            revert();
        }
    }

    //Buyer returns the item
    function returnItemToSeller(string _status) public {
        if (msg.sender != buyer) {
            revert();
        }

        if (now > receivedTime + timeToReturn) {
            revert();
        }

        status = _status;
    }

    //Seller releases balance to buyer and keep 25% for restocking fee
    function releaseBalanceToBuyer() public {
        if (msg.sender != seller) {
            revert();
        }

        selfdestruct(buyer);
    }

    //Buyer can withdraw deposit if escrow is expired
    function withdraw() public {
        if (!isExpired()) {
            revert();
        }

        if (msg.sender == buyer) {
            selfdestruct(buyer); 
        } else {
            revert();
        }
    }

    // Seller cancel escrow and return all funds to buyer
    function cancel() public {
        if (msg.sender == seller) {
           selfdestruct(buyer); 
        } else {
           revert();
        }
    }

    function isExpired() private constant returns (bool) {
        if (now > startTime + timeToExpiry) {
            return true;
        } else {
           return false;
        }
    }
}