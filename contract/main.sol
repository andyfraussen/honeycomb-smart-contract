pragma solidity 0.4.24;

import "https://github.com/smartcontractkit/chainlink/evm/contracts/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/evm/contracts/vendor/Ownable.sol";

contract SunnyRental is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1*LINK/10; //payment is 0.100 but sol cannot work with decimals.

  uint256 public currentPrice;
  int256 public changeDay;
  bytes32 public lastMarket;
  address honeyCombWWOOracle = 0x4a3fbbb385b5efeb4bc84a25aaadcd644bd09721;

  event RequestEthereumPriceFulfilled(
    bytes32 indexed requestId,
    uint256 indexed price
  );
  
/*
   _____               
  / ____|              
 | |     ___  _ __ ___ 
 | |    / _ \| '__/ _ \
 | |___| (_) | | |  __/
  \_____\___/|_|  \___|
*/

  constructor() public Ownable() {
    setPublicChainlinkToken();
    setChainlinkOracle(honeyCombWWOOracle);
  }
  
  function updateWeather() public {
      //call HC API for 
  }
  function runTest() public {
      Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32("4244dffd103a4d81aed90458ee6221f8"), this, this.fulfillEthereumPrice.selector);
    req.add("get", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD");
    req.add("path", "USD");
    req.addInt("times", 100);
    sendChainlinkRequestTo(0x9f37f5f695cc16bebb1b227502809ad0fb117e08, req, ORACLE_PAYMENT);
  }
  

  function fulfillEthereumPrice(bytes32 _requestId, uint256 _price)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestEthereumPriceFulfilled(_requestId, _price);
    currentPrice = _price;
  }
  
  
/*
  _      _____ _   _ _  __   ____                       _   _                 
 | |    |_   _| \ | | |/ /  / __ \                     | | (_)                
 | |      | | |  \| | ' /  | |  | |_ __   ___ _ __ __ _| |_ _  ___  _ __  ___ 
 | |      | | | . ` |  <   | |  | | '_ \ / _ \ '__/ _` | __| |/ _ \| '_ \/ __|
 | |____ _| |_| |\  | . \  | |__| | |_) |  __/ | | (_| | |_| | (_) | | | \__ \
 |______|_____|_| \_|_|\_\  \____/| .__/ \___|_|  \__,_|\__|_|\___/|_| |_|___/
                                  | |                                         
                                  |_|                                         
*/
 
  function getChainlinkToken() public view returns (address) {
    return chainlinkTokenAddress();
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }
  
  /*
   _    _      _                    __                  _   _                 
 | |  | |    | |                  / _|                | | (_)                
 | |__| | ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___ 
 |  __  |/ _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
 | |  | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
 |_|  |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
               | |                                                           
               |_|                                                           
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