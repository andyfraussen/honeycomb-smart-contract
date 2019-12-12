(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
module.exports=[
  {
    "constant": false,
    "inputs": [
      {
        "name": "_requestId",
        "type": "bytes32"
      },
      {
        "name": "_avgWindSpeedKmph",
        "type": "uint256"
      }
    ],
    "name": "fulfillWorldWeatherOnlineRequest",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_equipmentId",
        "type": "uint256"
      },
      {
        "name": "_rentalId",
        "type": "uint256"
      },
      {
        "name": "_date",
        "type": "string"
      },
      {
        "name": "_requiredWindspeedKmph",
        "type": "uint256"
      },
      {
        "name": "_location",
        "type": "string"
      },
      {
        "name": "_serviceFee",
        "type": "uint256"
      },
      {
        "name": "_rentalCompany",
        "type": "address"
      }
    ],
    "name": "registerRentalContract",
    "outputs": [],
    "payable": true,
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "renounceOwnership",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_equipmentId",
        "type": "uint256"
      },
      {
        "name": "_rentalId",
        "type": "uint256"
      }
    ],
    "name": "requestSettlement",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_rentalId",
        "type": "uint256"
      },
      {
        "name": "_date",
        "type": "string"
      },
      {
        "name": "_location",
        "type": "string"
      }
    ],
    "name": "requestWindSpeedFromOracle",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_newOwner",
        "type": "address"
      }
    ],
    "name": "transferOwnership",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "withdrawLink",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "name": "requestId",
        "type": "bytes32"
      },
      {
        "indexed": true,
        "name": "avgWindSpeedKmph",
        "type": "uint256"
      }
    ],
    "name": "RequestWWODataFulfilled",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "name": "_equipmentId",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "_rentalId",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "_date",
        "type": "string"
      }
    ],
    "name": "AllWeatherRetrievedEvent",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "name": "rentalId",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "equipmentId",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "avgWindSpeedKmph",
        "type": "uint256"
      }
    ],
    "name": "RequestingSettlement",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "name": "previousOwner",
        "type": "address"
      }
    ],
    "name": "OwnershipRenounced",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "name": "previousOwner",
        "type": "address"
      },
      {
        "indexed": true,
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "OwnershipTransferred",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "name": "id",
        "type": "bytes32"
      }
    ],
    "name": "ChainlinkRequested",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "name": "id",
        "type": "bytes32"
      }
    ],
    "name": "ChainlinkFulfilled",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "name": "id",
        "type": "bytes32"
      }
    ],
    "name": "ChainlinkCancelled",
    "type": "event"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_equipmentId",
        "type": "uint256"
      },
      {
        "name": "_date",
        "type": "string"
      }
    ],
    "name": "equipmentAvailable",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "getChainlinkToken",
    "outputs": [
      {
        "name": "",
        "type": "address"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "owner",
    "outputs": [
      {
        "name": "",
        "type": "address"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_date",
        "type": "string"
      },
      {
        "name": "_location",
        "type": "string"
      }
    ],
    "name": "windspeedForDay",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_date",
        "type": "string"
      },
      {
        "name": "_location",
        "type": "string"
      }
    ],
    "name": "windspeedWasRetrieved",
    "outputs": [
      {
        "name": "retrieved",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }
]

},{}],2:[function(require,module,exports){
let abi = require('./abi.json');

let availableButton = document.getElementById('availableButton')
let registerButton = document.getElementById('registerButton')
let confirmButton = document.getElementById('confirmButton')

availableButton.onclick = async () => {
    if (window.ethereum) {
        //window.web3 = new Web3(ethereum);
        try {
            await ethereum.enable();
            let contract = web3.eth.contract(abi);
            let contractInstance = contract.at('0x40D8d66A03c1c2949837FffC241CE078AD0B15FA')

            let equipmentid = parseInt(document.getElementById('equipmentId').value);
            let rentalId = parseInt(Math.floor(Math.random() * 101));
            let equipmentIdGroup = document.getElementById('equipmentId').value
            let date = document.getElementById('rentalDate').value
            let windspeed = parseInt(document.getElementById('windspeedSelect').value)
            let location = document.getElementById('locationSelect').value
            let serviceFee = 10000

            contractInstance.equipmentAvailable(equipmentid, date.toString(), (e, f) => {
                if (f === true) {
                    alert('Date is still available! Continue to the last step to register the rental')
                }
            })
            document.getElementById('equipmentIdGroup').innerText = 'Equipment ID: '+equipmentid
            document.getElementById('dateGroup').innerText = 'Date: ' + date
            document.getElementById('rentalIdGroup').innerText = 'RentalID: ' + rentalId
            document.getElementById('LocationGroup').innerText = 'Location: ' + location
            document.getElementById('WindspeedGroup').innerText = 'Min windspeed: ' + windspeed
            document.getElementById('serviceFeeGroup').innerText = 'Servicefee: ' + serviceFee
            let amount = 10000000000000000
            let gasValue = 500000

            registerButton.onclick = function () {
                contractInstance.registerRentalContract(equipmentid, rentalId, date.toString(), windspeed, location, serviceFee, '0xdB824df2788FF1Cb086773a94708e690EA555b91',
                    {from: window.web3.currentProvider.selectedAddress, value: amount, gas: gasValue, gasPrice: 10000}, (err, call) => {
                        console.log(err, call)
                    })
                document.getElementById('confirmEquipment').value = equipmentid
                document.getElementById('confirmRental').value = rentalId
            }

            confirmButton.onclick = function(){

                let equipmentConfirm = parseInt(document.getElementById('confirmEquipment').value)
                let rentalConfirm = parseInt(document.getElementById('confirmRental').value)

                contractInstance.requestSettlement(equipmentConfirm, rentalConfirm, (err, call) => {
                    console.log(err, call)})
            }

        } catch (error) {
            // User denied account access...
            //alert("We couldn't connect to MetaMask. Please check if you're logged in or MetaMask is installed!")
        }
    }
}





},{"./abi.json":1}]},{},[2]);
