pragma solidity 0.4.24;

import "https://github.com/smartcontractkit/chainlink/evm/contracts/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/evm/contracts/vendor/Ownable.sol";


contract SunnyRental is ChainlinkClient, Ownable {
    
    
    //private vars
    uint256 constant private ORACLE_PAYMENT = 1*LINK/10; //payment is 0.100 but sol cannot work with decimals.
    address private honeycombWWOOracle = 0x4a3fbbb385b5efeb4bc84a25aaadcd644bd09721;
    string private honeycombWWOPastWeatherInt256JobId = "67c9353f7cc94102b750f84f32027217";
    
    struct RentalContract {
        // Param _equipmentId the ID of the equipment being rented, which could for example be surfboards or kites.
        uint256 equipmentId;
        //Unique ID for this rental, as single user might be able to rent twice, we need distinction
        uint256 rentalId;
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
        //the ID for the payout CL fulfillment request for this contract.
        string payoutRequestId;
    }
    
     //maps equipmentId to a list of rental contracts for that equipmentId.
    mapping(uint256 => RentalContract[]) rentalContracts;
    //maps the payout request id to the equipmentId for later lookup. (avoid looping over every equipmentId in `rentalContracts` mapping)
    mapping(bytes32 => uint256) payoutRequests;

    constructor() public Ownable() {
        setPublicChainlinkToken();
        setChainlinkOracle(honeycombWWOOracle);
    }

    //event definitions
    event RequestWWODataFulfilled(bytes32 indexed requestId,int256 indexed data);
        
    
    
    /**
    ** Registers a new campaign
    **
    ** Param _equipmentId the ID of the equipment being rented, which could for example be surfboards or kites.
    ** Param _rentalId unique ID for this rental, as single user might be able to rent twice, we need distinction
    ** Param _startDate the start date of the rental that is requested
    ** Param _endDate the end date of the rental that is requested
    ** Param _minWindspeedKmph the minimum average daily windspeed required for the rental fee to be paid out.
    ** Param _serviceFeePct the percentage of the rental amount the rental company still gets when conditions are not met.
    **
    ** Payable ensures the client can deposit ether that will be paid out to the rental company when the weatherconditions are met.
    **
    ** Due to `require`, the txn will fail if conditions not met
    **/
    function registerRentalContract(uint256 _equipmentId,uint256 _rentalId,uint256 _startDate,uint256 _endDate, uint256 _minWindspeedKmph,uint256 _serviceFeePct) public payable {
        //validate input dates
        require(_startDate < _endDate && _startDate > now,"invalid period given");
        
        //validate that the equipment is available during the requested period
        require(equipmentAvailableDuringPeriod(_equipmentId,_startDate,_endDate) == true, "equipment not available in given period");

        //if all checks passed, register the rental contract
        rentalContracts[_equipmentId].push(RentalContract(
            _equipmentId,
            _rentalId,
            msg.sender, //customer
            _startDate,
            _endDate,
            _minWindspeedKmph,
            msg.value, //amount
            _serviceFeePct,
            ""));
    }
    
    /**
    ** Validates if a certain equipment is available for rent during the given period.
    ** 
    ** 
    ** 
    ** 
    ** Param _startDate the start date of the rental that is requested
    ** Param _endDate the end date of the rental that is requested
    */
    function equipmentAvailableDuringPeriod(uint256 _equipmentId,uint256 _startDate,uint256 _endDate) private returns (bool){
        RentalContract[] storage rentalContractsForEquipmentId =  rentalContracts[_equipmentId];
        for (uint i=0; i<rentalContractsForEquipmentId.length; i++) {
            //startdate falls somewhere between existing renting period -- already booked
            if(rentalContractsForEquipmentId[i].startDate < _startDate && _startDate < rentalContractsForEquipmentId[i].endDate){
                return false;
            }
            //enddate falls somewhere between existing renting period -- already booked
            if(rentalContractsForEquipmentId[i].startDate < _endDate && _endDate < rentalContractsForEquipmentId[i].endDate){
                return false;
            }
        }
        //no clashes, available for renting
        return true;
    }
    
    function requestSettlement(uint256 _equipmentId,uint256 _rentalId) public view {
        RentalContract[] storage contractsForEquipmentId =  rentalContracts[_equipmentId];
        RentalContract rentalContract;
        for (uint i=0; i<contractsForEquipmentId.length; i++) {
            if(contractsForEquipmentId[i].rentalId == _rentalId){
                rentalContract = contractsForEquipmentId[i];
                break;
            }
        }
        require(rentalContract.customer != 0, "rental contract not found");
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