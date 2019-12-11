pragma solidity 0.4.24;

import "https://github.com/smartcontractkit/chainlink/evm/contracts/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/evm/contracts/vendor/Ownable.sol";
//import "https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/1ea8ef42b3d8db17b910b46e4f8c124b59d77c03/contracts/BokkyPooBahsDateTimeLibrary.sol";

contract SunnyRental is ChainlinkClient, Ownable {
    
    uint256 retrievedSpeed;
    
    uint256 constant private ORACLE_PAYMENT = 1*LINK/10;
    address constant private honeycombWWOOracle = 0x4a3fbbb385b5efeb4bc84a25aaadcd644bd09721;
    string constant private honeycombWWOPastWeatherUInt256JobId = "58140c87248b4990809e3087f0774a0b";
    
    struct RentalContract {
        uint256 equipmentId; // Param _equipmentId the ID of the equipment being rented, which could for example be surfboards or kites.
        uint256 rentalId; //Unique ID for this rental, as single user might be able to rent twice, we need distinction
        address customer; //address of the customer that initiates the rental contract
        address company; //address of the company offering the rental
        string date; //first day of the rental - inclusive
        string location; //location of the rental
        uint256 requiredWindspeedKmph; //the average daily windspeed that is required for the rental to be paid out fully
        uint256 amount; //the total amount to be paid after successful rental.
        uint256 serviceFee; //the service fee that is paid out in case requirements are not met. `amount`-`serviceFee` is returned to the customer.
        bool payoutDone; //check if payout already happened
    }
    
    //storing the retrieved windspeeds for a specific date and location
    struct DailyWindSpeed {
        string date;
        string location;
        uint256 speed;
    }
    
    mapping(uint256 => RentalContract[]) rentalContracts; //maps equipmentId to a list of rental contracts for that equipmentId, used to loop over when checking availability.
    
    mapping(uint256 => uint256) equipmentForRentalId; //mapping to later better retrieve value
    
    mapping(bytes32 => uint256) chainlinkRequests; //maps the request id to the equipmentId for later lookup. (avoid looping over every equipmentId in `rentalContracts` mapping)
    
    mapping(string => DailyWindSpeed[]) dailyWindSpeedsForLocation; //maps location to the retrieved windspeeds for that location

    constructor() public Ownable() {
        setPublicChainlinkToken();
        setChainlinkOracle(honeycombWWOOracle);
    }

    //event definitions
    event RequestWWODataFulfilled(bytes32 indexed requestId,uint256 indexed avgWindSpeedKmph);
    event AllWeatherRetrievedEvent(uint256 _equipmentId,uint256 _rentalId, string _date);
    event RequestingSettlement(uint256 rentalId,uint256 equipmentId,uint256 avgWindSpeedKmph);
    
    function getRetrievedSpeed() public view returns (uint256){
        return retrievedSpeed;
    }
    /**
    ** Registers a new campaign
    **
    ** Param _equipmentId the ID of the equipment being rented, which could for example be surfboards or kites.
    ** Param _rentalId unique ID for this rental, as single user might be able to rent twice, we need distinction
    ** Param _startDate the start date of the rental that is requested
    ** Param _endDate the end date of the rental that is requested
    ** Param _minWindspeedKmph the minimum average daily windspeed required for the rental fee to be paid out.
    ** Param _serviceFee the amount the rental company still gets when conditions are not met.
    **
    ** Payable ensures the client can deposit ether that will be paid out to the rental company when the weatherconditions are met.
    **
    ** Due to `require`, the txn will fail if conditions not met
    **/
    function registerRentalContract(uint256 _equipmentId,uint256 _rentalId,string _date, uint256 _requiredWindspeedKmph,string _location, uint256 _serviceFee, address _rentalCompany) public payable {

        //validate that the equipment is available during the requested period
        require(equipmentAvailable(_equipmentId,_date) == true, "equipment not available in given period");
        
        require(_serviceFee < msg.value,"rental fee must be smaller than the total amount paid");
        
        //if all checks passed, register the rental contract
        RentalContract memory r;
        
        r.equipmentId= _equipmentId;
        r.rentalId = _rentalId;
        r.customer = msg.sender;
        r.date = _date;
        r.requiredWindspeedKmph = _requiredWindspeedKmph;
        r.amount = msg.value;
        r.serviceFee = _serviceFee;
        r.company = _rentalCompany;
        r.location = _location;
        
        equipmentForRentalId[_rentalId] = _equipmentId;
            
        rentalContracts[_equipmentId].push(r);
    }
    
   /**
    ** Validates if a certain equipment is available for rent for a given date.
    ** 
    ** Param _equipmentId the equipmentId to check availability for
    ** Param _date the date of the rental that is requested
    */
    function equipmentAvailable(uint256 _equipmentId,string _date) public view returns (bool){
        RentalContract[] storage rentalContractsForEquipmentId =  rentalContracts[_equipmentId];
        for (uint i=0; i<rentalContractsForEquipmentId.length; i++) {
            //if date is already there, it's booked. minimized version of rental period (from-to) due to conversion issues between int and timestmap string.
            if(compareStrings(rentalContractsForEquipmentId[i].date,_date)){
                return false;
            }
        }
        //no clashes, available for renting
        return true;
    }
    
   /**
    ** Requests settlement of a rental contract. Will trigger Oracle info retrieval for given date.
    ** 
    ** Param _equipmentId the equipment ID that was rental
    ** Param _rentalId the rentalId for the renting agreement
    */
    function requestSettlement(uint256 _equipmentId,uint256 _rentalId) public {
        RentalContract memory r = getRentalContract(_equipmentId,_rentalId);
        require(r.customer != 0, "rental contract not found");
        
        //no need to pay twice
        if (r.payoutDone){
            return;
        }
        
        //if we don't have the weather yet, ask the oracle very nicely.
        if(!windspeedWasRetrieved(r.date,r.location)){
            requestWindSpeedFromOracle(r.rentalId,r.date,r.location);
        }else{
            emit AllWeatherRetrievedEvent(_equipmentId,_rentalId,r.date);
            //validatePayoutRequirements(_equipmentId,_rentalId);
        }
        
        // WE FIRST WORKED WITH INTEGER EPOCH TIMESTAMPS, TO HAVE MULTI-DAY RENTAL PERIODS. HOWEVER WE LOST 1 WEEK OF TIMESTAMPS
        // WITH EPOCH INT CONVERSION INTO STRING TIMESTAMP FOR THE WWO API WHICH TAKES ONLY STRINGS. LAST RESORT UNDO ALL THE WORKED
        // AND GO BACK TO THE BASICS WITH SINGLE DAY RENTALS.
        
        // bool allWeatherRetrieved = true;
        // for(uint256 ts = r.startDate;ts < r.endDate;ts +=dayInSeconds){
        //     string memory dayString = timestampToDateString(ts);
        //     if(!weatherWasRetrieved(dayString,_rentalId)){
        //         allWeatherRetrieved = false;
        //         break;
        //     }
        // }
        // //if we did not have to retrieve new weather data, we can continue with settlement.
        // if(allWeatherRetrieved){
        //     emit AllWeatherRetrievedEvent(_equipmentId,_rentalId);
        //     validatePayoutRequirements(_equipmentId,_rentalId);
        // }
  }
  
  function getRentalContract(uint256 _equipmentId,uint256 _rentalId) private view returns (RentalContract){
      RentalContract[] storage contractsForEquipmentId =  rentalContracts[_equipmentId];
        for (uint i=0; i<contractsForEquipmentId.length; i++) {
            if(contractsForEquipmentId[i].rentalId == _rentalId){
                return contractsForEquipmentId[i];
            }
        }
        return;
  }



/**
 **  Oracle functions
 **/

    function requestWindSpeedFromOracle(uint256 _rentalId,string _date,string _location)  {
      //docs @ https://www.worldweatheronline.com/developer/api/docs/historical-weather-api.aspx
      Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(honeycombWWOPastWeatherUInt256JobId), this, this.fulfillWorldWeatherOnlineRequest.selector);
      req.add("q",_location);
      req.add("date",_date);
      req.add("tp","24");
      req.add("copyPath", "data.weather.0.hourly.0.windspeedKmph");
      bytes32 requestId = sendChainlinkRequestTo(chainlinkOracleAddress(), req, ORACLE_PAYMENT);
      chainlinkRequests[requestId] = _rentalId;
  }
  
/**
 ** callback function for WWO data.
 **/
 
  function fulfillWorldWeatherOnlineRequest(bytes32 _requestId, uint256 _avgWindSpeedKmph) public recordChainlinkFulfillment(_requestId){
      retrievedSpeed = _avgWindSpeedKmph;
      emit RequestWWODataFulfilled(_requestId, _avgWindSpeedKmph);
      uint256 rentalId = chainlinkRequests[_requestId];
      uint256 equipmentId = equipmentForRentalId[rentalId];
      emit RequestingSettlement(rentalId,equipmentId,_avgWindSpeedKmph);
      requestSettlement(equipmentId,rentalId);
  }
  
/**
 ** Public View functions, for validation and debugging
 **/ 
 
  function windspeedForDay(string _date,string _location) public view returns (uint256){
      for(uint i=0;i < dailyWindSpeedsForLocation[_location].length;i++){
          //loop over all speeds for this location to find the relevant day.
          if( compareStrings(dailyWindSpeedsForLocation[_location][i].date,_date) == true){
              return dailyWindSpeedsForLocation[_location][i].speed;
          }
      }
      return 0;
  }
  
  function windspeedWasRetrieved(string _date,string _location) public view returns (bool retrieved){
      for(uint i=0;i < dailyWindSpeedsForLocation[_location].length;i++){
          //loop over all speeds for this location to find the relevant day.
          if( compareStrings(dailyWindSpeedsForLocation[_location][i].date,_date) == true){
              return true;
          }
      }
      return false;
  }
  
  
/**
 **   LINK operations
 **/
 
  function getChainlinkToken() public view returns (address) {
    return chainlinkTokenAddress();
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }
  
  
/**
 **  Helper functions
 **/

    function compareStrings (string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly { // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }

// WE FIRST WORKED WITH INTEGER EPOCH TIMESTAMPS, TO HAVE MULTI-DAY RENTAL PERIODS. HOWEVER WE LOST 1 WEEK OF TIMESTAMPS
// WITH EPOCH INT CONVERSION INTO STRING TIMESTAMP FOR THE WWO API WHICH TAKES ONLY STRINGS. LAST RESORT UNDO ALL THE WORKED
// AND GO BACK TO THE BASICS WITH SINGLE DAY RENTALS.
// PLEASE SEE CONVERSATION ON DISCORD BETWEEN burak#3376 and Pega88#3410
        
   /**
    ** Validates if a certain equipment is available for rent during the given period.
    ** 
    ** Param _equipmentId the equipmentId to check availability for
    ** Param _startDate the start date of the rental that is requested
    ** Param _endDate the end date of the rental that is requested
    **/
    // function equipmentAvailableDuringPeriod(uint256 _equipmentId,uint256 _startDate,uint256 _endDate) public view returns (bool){
    //     RentalContract[] storage rentalContractsForEquipmentId =  rentalContracts[_equipmentId];
    //     for (uint i=0; i<rentalContractsForEquipmentId.length; i++) {
    //         //startdate falls somewhere between existing renting period -- already booked
    //         if(rentalContractsForEquipmentId[i].startDate <= _startDate && _startDate <= rentalContractsForEquipmentId[i].endDate){
    //             return false;
    //         }
    //         //enddate falls somewhere between existing renting period -- already booked
    //         if(rentalContractsForEquipmentId[i].startDate <= _endDate && _endDate <= rentalContractsForEquipmentId[i].endDate){
    //             return false;
    //         }
    //     }
    //     //no clashes, available for renting
    //     return true;
    // }
  
//   function validatePayoutRequirements(uint256 _equipmentId,uint256 _rentalId){
//       RentalContract memory r = getRentalContract(_equipmentId,_rentalId);
//       bool requirementsSatisfied = true;
//       //check if any of them do not meet requirements
//       for(uint i = 0 ; i < dailyWindSpeedsForRental[r.rentalId].length; i++){
//           DailyWindSpeed dailyWindSpeed = dailyWindSpeedsForRental[r.rentalId][i];
//           if(dailyWindSpeed.speed < r.dailyRequiredWindspeedKmph){
//               requirementsSatisfied = false;
//               break;
//           }
//       }
//       if(requirementsSatisfied){
//           r.company.transfer(r.amount);
//       }else{
//           r.company.transfer(r.serviceFee);
//           r.customer.transfer(r.amount-r.serviceFee);
//       }
//   }
  
  
//   function timestampToDateString(uint256 ts)public returns (string dateString){
//       uint year;
//       uint month;
//       uint day;
//       (year, month, day) = BokkyPooBahsDateTimeLibrary.timestampToDate(ts);
//       dateString = strConcat(uintToString(year),"-",uintToString(month),"-",uintToString(day));
//   }
  
//   function uintToString(uint v) private constant returns (string str) {
//         uint maxlength = 100;
//         bytes memory reversed = new bytes(maxlength);
//         uint i = 0;
//         while (v != 0) {
//             uint remainder = v % 10;
//             v = v / 10;
//             reversed[i++] = byte(48 + remainder);
//         }
//         bytes memory s = new bytes(i + 1);
//         for (uint j = 0; j <= i; j++) {
//             s[j] = reversed[i - j];
//         }
//         str = string(s);
//     }
    
//     function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
//         bytes memory _ba = bytes(_a);
//         bytes memory _bb = bytes(_b);
//         bytes memory _bc = bytes(_c);
//         bytes memory _bd = bytes(_d);
//         bytes memory _be = bytes(_e);
//         string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
//         bytes memory babcde = bytes(abcde);
//         uint k = 0;
//         for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
//         for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
//         for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
//         for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
//         for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
//         return string(babcde);
// }

}

