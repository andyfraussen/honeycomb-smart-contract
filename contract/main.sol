pragma solidity 0.4.24;

import "https://github.com/smartcontractkit/chainlink/evm/contracts/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/evm/contracts/vendor/Ownable.sol";

contract SunnyRental is ChainlinkClient, Ownable {
    uint256 constant private ORACLE_PAYMENT = 1*LINK/10; //payment is 0.100 but sol cannot work with decimals.
    uint256 public currentPrice;
    int256 public changeDay;
    bytes32 public lastMarket;
    address honeycombWWOOracle = 0x4a3fbbb385b5efeb4bc84a25aaadcd644bd09721;
    string honeycombWWOPastWeatherJobIdBytes32 = "dfd869c5bdc04724a4b334d4413d588b";
    string honeycombWWOPastWeatherJobIdInt256 = "67c9353f7cc94102b750f84f32027217";
    string honeycombWWOPastWeatherJobIdBool = "c7aa4fbc602a4962aec762fe3a9d36f4";

    event RequestWWODataFulfilled(
        bytes32 indexed requestId,
        bytes32 indexed data
        );
        
    constructor() public Ownable() {
        setPublicChainlinkToken();
        setChainlinkOracle(honeycombWWOOracle);
    }
    
    function updateWeather() public {
        //call HC API for yesterday's precipitation
        //https://www.worldweatheronline.com/developer/api/docs/historical-weather-api.aspx
        //Params: isDayTime 
        Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32("4244dffd103a4d81aed90458ee6221f8"), this, this.fulfillWorldWeatherOnlineRequest.selector);
        req.add("get", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD");
        sendChainlinkRequestTo(chainlinkOracleAddress(), req, ORACLE_PAYMENT);
  }
  /*
  callback function for WWO data.
  */
  function fulfillWorldWeatherOnlineRequest(bytes32 _requestId, bytes32 _data) public recordChainlinkFulfillment(_requestId){
    emit RequestWWODataFulfilled(_requestId, _data);
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