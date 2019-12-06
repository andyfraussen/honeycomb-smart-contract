pragma solidity 0.4.24;

import "https://github.com/smartcontractkit/chainlink/evm/contracts/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/evm/contracts/vendor/Ownable.sol";


contract SunnyRental is ChainlinkClient, Ownable {
    
    
    //private vars
    uint256 constant private ORACLE_PAYMENT = 1*LINK/10; //required oracle payment is 0.100 ether
    address constant private honeycombWWOOracle = 0x4a3fbbb385b5efeb4bc84a25aaadcd644bd09721;
    string constant private honeycombWWOPastWeatherInt256JobId = "67c9353f7cc94102b750f84f32027217";
    
    /**
     * The struct representing a single rental contract
     **/
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
        //the ID for the payout CL fulfillment request for this contract.
        string payoutRequestId;
    }
    
    //storing the retrieved windspeeds for the period of the rental
    struct DailyWindSpeed {
        uint256 date;
        uint256 speed;
        //TRUE if it was retrieved. default FALSE when it hasn't been retrieved.
        //Used to differ speed 0 from no speed retrieved (default uint value also 0) 
        bool retrieved;
    }
    
    //maps rentalId to the retrieved windspeeds for that day
    mapping(uint256 => DailyWindSpeed[]) dailyWindSpeedsForRentalId;
    
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
        require(_startDate < _endDate,"invalid period given"); //TODO after testing add  && _startDate > block.timestamp for real timestamp
        
        //validate that the equipment is available during the requested period
        require(equipmentAvailableDuringPeriod(_equipmentId,_startDate,_endDate) == true, "equipment not available in given period");
        
        //if all checks passed, register the rental contract
        RentalContract memory r;
        
        r.equipmentId= _equipmentId;
        r.rentalId = _rentalId;
        r.customer = msg.sender;
        r.startDate = _startDate;
        r.endDate = _endDate;
        r.dailyRequiredWindspeedKmph = _minWindspeedKmph;
        r.amount = msg.value;
        r.serviceFeePct = _serviceFeePct;
            
        rentalContracts[_equipmentId].push(r);
    }
    
    /**
    ** Validates if a certain equipment is available for rent during the given period.
    ** 
    ** Param _equipmentId the equipmentId to check availability for
    ** Param _startDate the start date of the rental that is requested
    ** Param _endDate the end date of the rental that is requested
    */
    function equipmentAvailableDuringPeriod(uint256 _equipmentId,uint256 _startDate,uint256 _endDate) public view returns (bool){
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
    
    function requestSettlement(uint256 _equipmentId,uint256 _rentalId) public {
        RentalContract[] storage contractsForEquipmentId =  rentalContracts[_equipmentId];
        RentalContract memory rentalContract;
        for (uint i=0; i<contractsForEquipmentId.length; i++) {
            if(contractsForEquipmentId[i].rentalId == _rentalId){
                rentalContract = contractsForEquipmentId[i];
                break;
            }
        }
        require(rentalContract.customer != 0, "rental contract not found");
    
        
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
    
    //add retrieved content to contract
    
    
  }
  
  function validatePayoutRequirements(uint256 _equipmentId,uint256 _rentalId) private {
      //check if all data is retrieved
      
      //if so, check if all requirements are met and relevant do payout(s)
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