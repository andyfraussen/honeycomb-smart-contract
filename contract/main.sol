pragma solidity 0.4.24;

import "https://github.com/smartcontractkit/chainlink/evm/contracts/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/evm/contracts/vendor/Ownable.sol";


contract SunnyRental is ChainlinkClient, Ownable {
    
    
    //private vars
    uint256 constant private ORACLE_PAYMENT = 1*LINK/10; //payment is 0.100 but sol cannot work with decimals.
    address private honeycombWWOOracle = 0x4a3fbbb385b5efeb4bc84a25aaadcd644bd09721;
    string private honeycombWWOPastWeatherInt256JobId = "67c9353f7cc94102b750f84f32027217";
    
    struct RentalContract {
        //the ID of the equipment being rented, i.e. surfboards or kites.
        string equipmentId;
        //address of the customer that initiates the rental contract
        address customer;
        //first day of the rental - inclusive
        uint256 startDate;
        //last day of the rental - inclusive
        uint256 endDate;
        //the average daily windspeed that is required for the contract to be 
        uint256 dailyRequiredWindspeedKmph;
        //the total amount to be paid after successful rental.
        uint256 amount;
        //the percentage of `amount` that is paid out as a service fee in case requirements are not met. `amount`-`serviceFeePct` is returned to the customer.
        uint256 serviceFeePct;
        //storing the retrieved windspeeds for the period of the rental
        //key: date, value: windspeed.
        mapping (uint256 => uint256) dailyWindSpeeds;
        //storing wether or not windspeed has been retrieved for a specific day. Useful for when windspeed is 0 as uint256 defaults to 0, we would not know if it was retrieved as 0 or defaulting to 0.
        //key: date, value: TRUE if it was retrieved. default FALSE when it hasn't been retrieved.
        mapping (uint256 => bool) dailyWindSpeedsRetrieved;
    }
    
     //maps equipmentId to his active rental contracts. Each equipment can only have one active contract at a time.
    mapping(string => RentalContract) rentalContracts;
    //maps the payout request id to the equipmentId it was requested for
    mapping(bytes32 => string) payoutRequests;

    constructor() public Ownable() {
        setPublicChainlinkToken();
        setChainlinkOracle(honeycombWWOOracle);
    }

    //event definitions
    event RequestWWODataFulfilled(bytes32 indexed requestId,int256 indexed data);
        
    
    
    /**
    ** Registers a new campaign
    **
    ** Param _rentalId
    ** Param _startDate
    ** Param _endDate
    ** Param _minWindspeedKmph the minimum average daily windspeed required for the rental fee to be paid out.
    ** Param _serviceFeePct the percentage of the rental amount the rental company still gets when conditions are not met.
    **
    ** Payable ensures the client can deposit ether that will be paid out to the rental company when the weatherconditions are met.
    **/
    function registerRentalContract(string _rentalId,uint256 _startDate,uint256 _endDate, uint256 _minWindspeedKmph,uint256 _serviceFeePct) public payable {
        
    }
    
    function requestSettlement(string equipmentId) public{
        //get the requirements for the contract : location & min windspeed
        
        //TODO
        
        //for each day we don't have an avg windspeed for that's within the rental contract timespan, request it.
        
        //TODO loop
        
        //call HC API for yesterday's daily average precipitation  - docs @ https://www.worldweatheronline.com/developer/api/docs/historical-weather-api.aspx
        Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(honeycombWWOPastWeatherInt256JobId), this, this.fulfillWorldWeatherOnlineRequest.selector);
        req.add("q","Brussels");
        req.add("date","2019-11-24");
        req.add("tp","24");
        //start with avg temp. later: windspeed for surfing
        req.add("copyPath", "data.weather.0.avgtempF");
        sendChainlinkRequestTo(chainlinkOracleAddress(), req, ORACLE_PAYMENT);
        
        //store that this CL request was made for the rentalContractId so we know in callback what to handle
  }
  
  /*
  callback function for WWO data.
  */
  function fulfillWorldWeatherOnlineRequest(bytes32 _requestId, int256 _avgTempF) public recordChainlinkFulfillment(_requestId){
    emit RequestWWODataFulfilled(_requestId, _avgTempF);
  }
  
/*
    LINK operations
 */
 
  function getChainlinkToken() public view returns (address) {
    return chainlinkTokenAddress();
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }
  
/*
    Helper functions
*/

  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly { // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }

}