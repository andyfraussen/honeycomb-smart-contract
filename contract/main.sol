pragma solidity 0.4.24;

import "https://github.com/smartcontractkit/chainlink/evm/contracts/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/evm/contracts/vendor/Ownable.sol";


contract SunnyRental is ChainlinkClient, Ownable {
    
    //public readable vars
    int256 public avgtempF;
    
    //private vars
    uint256 constant private ORACLE_PAYMENT = 1*LINK/10; //payment is 0.100 but sol cannot work with decimals.
    address private honeycombWWOOracle = 0x4a3fbbb385b5efeb4bc84a25aaadcd644bd09721;
    string private honeycombWWOPastWeatherInt256JobId = "67c9353f7cc94102b750f84f32027217";


    //event definitions
    event RequestWWODataFulfilled(bytes32 indexed requestId,int256 indexed data);
        
    constructor() public Ownable() {
        setPublicChainlinkToken();
        setChainlinkOracle(honeycombWWOOracle);
    }
    /* Public function to trigger fulfillment */
    function updateWeather(string rentalContractId) public {
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
    avgtempF = _avgTempF;
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